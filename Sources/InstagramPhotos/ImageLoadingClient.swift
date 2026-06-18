import CoreGraphics
import Foundation
import ImageIO
import Photos
#if canImport(UIKit)
import UIKit
#endif

public struct ImageLoadResult: Sendable {
    public let cgImage: CGImage
    public let isInCloud: Bool

    public init(cgImage: CGImage, isInCloud: Bool) {
        self.cgImage = cgImage
        self.isInCloud = isInCloud
    }
}

private struct ImageRequestStrategy {
    let deliveryMode: PHImageRequestOptionsDeliveryMode
    let resizeMode: PHImageRequestOptionsResizeMode
    let version: PHImageRequestOptionsVersion
    /// When `true`, opportunistic degraded frames may be returned immediately (grid thumbnails).
    let acceptsDegradedImage: Bool
}

/// Loads images from PhotoKit on a dedicated serial queue to avoid blocking the main actor.
public final class ImageLoadingClient: @unchecked Sendable {
    private let configuration: InstagramPhotosPickerConfiguration
    private let imageManager: PHCachingImageManager
    private let photoKitQueue = DispatchQueue(label: "InstagramPhotos.PhotoKit", qos: .userInitiated)
    private var activeRequests: [String: PHImageRequestID] = [:]
    private var assetCache: [String: PHAsset] = [:]
    private let isPreviewMode: Bool
    private let displayScale: CGFloat

    public init(
        configuration: InstagramPhotosPickerConfiguration = .init(),
        imageManager: PHCachingImageManager = PHCachingImageManager(),
        isPreviewMode: Bool = false,
        displayScale: CGFloat? = nil
    ) {
        self.configuration = configuration
        self.imageManager = imageManager
        self.isPreviewMode = isPreviewMode
        self.displayScale = displayScale ?? PhotoKitImageSizing.displayScale()
    }

    #if DEBUG
    public static var preview: ImageLoadingClient {
        ImageLoadingClient(configuration: .init(), isPreviewMode: true)
    }
    #endif

    public func prepareAssets(ids: [String]) {
        photoKitQueue.async { [weak self] in
            guard let self else { return }
            for id in ids {
                _ = self.cachedAssetOnQueue(for: id)
            }
        }
    }

    public func ensurePrepared(assetID: String) async {
        _ = await cachedAsset(for: assetID)
    }

    public func loadThumbnail(
        for asset: InstagramPhotosAsset,
        targetSize: CGSize,
        allowsNetwork: Bool = false
    ) async throws -> ImageLoadResult {
        if isPreviewMode {
            return try previewThumbnail(for: asset)
        }

        guard let phAsset = await cachedAsset(for: asset.id) else {
            throw InstagramPhotosImageLoadingError.assetNotFound
        }
        guard phAsset.mediaType == .image else {
            throw InstagramPhotosImageLoadingError.imageUnavailable
        }

        let pixelSize = PhotoKitImageSizing.pixelSize(for: targetSize, scale: displayScale)
        do {
            return try await requestCGImageWithFallbacks(
                key: "thumb-\(asset.id)",
                asset: phAsset,
                targetSize: pixelSize,
                allowsNetwork: allowsNetwork,
                strategies: Self.thumbnailStrategies,
                progress: nil
            )
        } catch {
            return try await requestThumbnailData(
                key: "thumb-\(asset.id)-data",
                asset: phAsset,
                maxPixelSize: Int(max(pixelSize.width, pixelSize.height)),
                allowsNetwork: allowsNetwork
            )
        }
    }

    public func loadDisplayImage(
        for asset: InstagramPhotosAsset,
        targetSize: CGSize,
        allowsNetwork: Bool = false
    ) async throws -> ImageLoadResult {
        if isPreviewMode {
            return try previewThumbnail(for: asset)
        }

        guard let phAsset = await cachedAsset(for: asset.id) else {
            throw InstagramPhotosImageLoadingError.assetNotFound
        }
        guard phAsset.mediaType == .image else {
            throw InstagramPhotosImageLoadingError.imageUnavailable
        }

        let pixelSize = PhotoKitImageSizing.pixelSize(for: targetSize, scale: displayScale)
        return try await loadPreviewImage(
            for: asset,
            targetSize: targetSize,
            allowsNetwork: allowsNetwork
        )
    }

    public func loadFullSizeImage(
        for asset: InstagramPhotosAsset,
        progress: (@Sendable (Double) -> Void)? = nil
    ) async throws -> CGImage {
        if isPreviewMode {
            return try await previewFullSizeImage(for: asset, progress: progress)
        }

        guard let phAsset = await cachedAsset(for: asset.id) else {
            throw InstagramPhotosImageLoadingError.assetNotFound
        }
        guard phAsset.mediaType == .image else {
            throw InstagramPhotosImageLoadingError.imageUnavailable
        }

        do {
            let (data, info) = try await requestImageData(
                key: "full-\(asset.id)",
                asset: phAsset,
                deliveryMode: .highQualityFormat,
                allowsNetwork: configuration.iCloudNetworkAccessAllowed,
                progress: progress
            )

            if PHAssetCloudStatus.isInCloud(info: info), !configuration.iCloudNetworkAccessAllowed {
                throw InstagramPhotosImageLoadingError.networkAccessDisabled
            }

            if let cgImage = CGImageDecoding.decodeFullSize(from: data) {
                return cgImage
            }
        } catch {
            if case InstagramPhotosImageLoadingError.networkAccessDisabled = error {
                throw error
            }
        }

        let result = try await requestCGImageWithFallbacks(
            key: "full-\(asset.id)",
            asset: phAsset,
            targetSize: PhotoKitImageSizing.fullSizeTarget(for: phAsset),
            allowsNetwork: configuration.iCloudNetworkAccessAllowed,
            strategies: Self.fullSizeStrategies,
            progress: progress
        )

        if result.isInCloud, !configuration.iCloudNetworkAccessAllowed {
            throw InstagramPhotosImageLoadingError.networkAccessDisabled
        }

        return result.cgImage
    }

    public func startCaching(assetIDs: [String], targetSize: CGSize) {
        photoKitQueue.async { [weak self] in
            guard let self else { return }
            let phAssets = assetIDs.compactMap { self.cachedAssetOnQueue(for: $0) }
            guard !phAssets.isEmpty else { return }

            let pixelSize = PhotoKitImageSizing.pixelSize(for: targetSize, scale: self.displayScale)
            let options = self.thumbnailOptions(allowsNetwork: false)
            self.imageManager.startCachingImages(
                for: phAssets,
                targetSize: pixelSize,
                contentMode: .aspectFill,
                options: options
            )
        }
    }

    public func stopCaching(assetIDs: [String], targetSize: CGSize) {
        photoKitQueue.async { [weak self] in
            guard let self else { return }
            let phAssets = assetIDs.compactMap { self.cachedAssetOnQueue(for: $0) }
            guard !phAssets.isEmpty else { return }

            let pixelSize = PhotoKitImageSizing.pixelSize(for: targetSize, scale: self.displayScale)
            let options = self.thumbnailOptions(allowsNetwork: false)
            self.imageManager.stopCachingImages(
                for: phAssets,
                targetSize: pixelSize,
                contentMode: .aspectFill,
                options: options
            )
        }
    }

    public func cancel(for key: String) {
        photoKitQueue.async { [weak self] in
            self?.cancelOnQueue(matching: key)
        }
    }

    public func cancelAll() {
        photoKitQueue.async { [weak self] in
            guard let self else { return }
            let requestIDs = Array(self.activeRequests.values)
            self.activeRequests.removeAll()
            for requestID in requestIDs {
                self.imageManager.cancelImageRequest(requestID)
            }
        }
    }

    public func loadPreviewImage(
        for asset: InstagramPhotosAsset,
        targetSize: CGSize,
        allowsNetwork: Bool = true
    ) async throws -> ImageLoadResult {
        if isPreviewMode {
            return try previewThumbnail(for: asset)
        }

        guard let phAsset = await cachedAsset(for: asset.id) else {
            throw InstagramPhotosImageLoadingError.assetNotFound
        }
        guard phAsset.mediaType == .image else {
            throw InstagramPhotosImageLoadingError.imageUnavailable
        }

        let pixelSize = PhotoKitImageSizing.pixelSize(for: targetSize, scale: displayScale)

        do {
            return try await requestCGImageWithFallbacks(
                key: "preview-\(asset.id)",
                asset: phAsset,
                targetSize: pixelSize,
                allowsNetwork: allowsNetwork,
                strategies: Self.previewStrategies,
                progress: nil
            )
        } catch {
            return try await requestThumbnailData(
                key: "preview-\(asset.id)-data",
                asset: phAsset,
                maxPixelSize: Int(max(pixelSize.width, pixelSize.height)),
                allowsNetwork: allowsNetwork
            )
        }
    }

    private static let previewStrategies: [ImageRequestStrategy] = [
        ImageRequestStrategy(
            deliveryMode: .highQualityFormat,
            resizeMode: .fast,
            version: .current,
            acceptsDegradedImage: false
        ),
        ImageRequestStrategy(
            deliveryMode: .opportunistic,
            resizeMode: .fast,
            version: .current,
            acceptsDegradedImage: false
        ),
        ImageRequestStrategy(
            deliveryMode: .highQualityFormat,
            resizeMode: .fast,
            version: .unadjusted,
            acceptsDegradedImage: false
        ),
    ]

    private static let thumbnailStrategies: [ImageRequestStrategy] = [
        ImageRequestStrategy(
            deliveryMode: .highQualityFormat,
            resizeMode: .fast,
            version: .current,
            acceptsDegradedImage: false
        ),
        ImageRequestStrategy(
            deliveryMode: .opportunistic,
            resizeMode: .fast,
            version: .current,
            acceptsDegradedImage: false
        ),
        ImageRequestStrategy(
            deliveryMode: .fastFormat,
            resizeMode: .fast,
            version: .unadjusted,
            acceptsDegradedImage: true
        ),
    ]

    private static let fullSizeStrategies: [ImageRequestStrategy] = [
        ImageRequestStrategy(
            deliveryMode: .highQualityFormat,
            resizeMode: .fast,
            version: .current,
            acceptsDegradedImage: false
        ),
        ImageRequestStrategy(
            deliveryMode: .opportunistic,
            resizeMode: .fast,
            version: .current,
            acceptsDegradedImage: false
        ),
        ImageRequestStrategy(
            deliveryMode: .highQualityFormat,
            resizeMode: .fast,
            version: .unadjusted,
            acceptsDegradedImage: false
        ),
    ]

    private func requestCGImageWithFallbacks(
        key: String,
        asset: PHAsset,
        targetSize: CGSize,
        allowsNetwork: Bool,
        strategies: [ImageRequestStrategy],
        progress: (@Sendable (Double) -> Void)?
    ) async throws -> ImageLoadResult {
        var lastError: Error = InstagramPhotosImageLoadingError.imageUnavailable

        for (index, strategy) in strategies.enumerated() {
            do {
                let (cgImage, info) = try await requestCGImage(
                    key: "\(key)-\(index)",
                    asset: asset,
                    targetSize: targetSize,
                    strategy: strategy,
                    allowsNetwork: allowsNetwork,
                    progress: progress
                )
                return ImageLoadResult(
                    cgImage: cgImage,
                    isInCloud: PHAssetCloudStatus.isInCloud(info: info)
                )
            } catch {
                lastError = error
                if case InstagramPhotosImageLoadingError.cancelled = error {
                    throw error
                }

                if strategies.count == 1 || index == strategies.count - 1 {
                    break
                }
            }
        }

        throw lastError
    }

    private func requestThumbnailData(
        key: String,
        asset: PHAsset,
        maxPixelSize: Int,
        allowsNetwork: Bool
    ) async throws -> ImageLoadResult {
        let (data, info) = try await requestImageData(
            key: key,
            asset: asset,
            deliveryMode: .fastFormat,
            allowsNetwork: allowsNetwork,
            progress: nil
        )

        guard let cgImage = CGImageDecoding.decodeThumbnail(from: data, maxPixelSize: maxPixelSize) else {
            throw InstagramPhotosImageLoadingError.imageUnavailable
        }

        return ImageLoadResult(
            cgImage: cgImage,
            isInCloud: PHAssetCloudStatus.isInCloud(info: info)
        )
    }

    private func cachedAsset(for id: String) async -> PHAsset? {
        await withCheckedContinuation { continuation in
            photoKitQueue.async { [weak self] in
                continuation.resume(returning: self?.cachedAssetOnQueue(for: id))
            }
        }
    }

    private func cachedAssetOnQueue(for id: String) -> PHAsset? {
        if let cached = assetCache[id] {
            return cached
        }

        let asset = PHAsset.fetchAssets(withLocalIdentifiers: [id], options: nil).firstObject
        if let asset {
            assetCache[id] = asset
        }
        return asset
    }

    private func requestCGImage(
        key: String,
        asset: PHAsset,
        targetSize: CGSize,
        strategy: ImageRequestStrategy,
        allowsNetwork: Bool,
        progress: (@Sendable (Double) -> Void)?
    ) async throws -> (CGImage, [AnyHashable: Any]?) {
        try Task.checkCancellation()

        return try await withTaskCancellationHandler {
            try await withCheckedThrowingContinuation { continuation in
                let guardState = ContinuationGuard()
                let fallback = ImageRequestFallback()

                photoKitQueue.async { [weak self] in
                    guard let self else {
                        guardState.resumeOnce(continuation, throwing: InstagramPhotosImageLoadingError.cancelled)
                        return
                    }

                    self.cancelOnQueue(for: key)

                    let options = PHImageRequestOptions()
                    options.deliveryMode = strategy.deliveryMode
                    options.resizeMode = strategy.resizeMode
                    options.version = strategy.version
                    options.isNetworkAccessAllowed = allowsNetwork
                    options.isSynchronous = false

                    if allowsNetwork, let progress {
                        options.progressHandler = { value, _, _, _ in
                            progress(value)
                        }
                    }

                    let requestID = self.imageManager.requestImage(
                        for: asset,
                        targetSize: targetSize,
                        contentMode: .aspectFill,
                        options: options
                    ) { image, info in
                        self.photoKitQueue.async {
                            if let cancelled = info?[PHImageCancelledKey] as? Bool, cancelled {
                                if let fallbackResult = fallback.value {
                                    guardState.resumeOnce(continuation, returning: fallbackResult)
                                } else {
                                    guardState.resumeOnce(
                                        continuation,
                                        throwing: InstagramPhotosImageLoadingError.cancelled
                                    )
                                }
                                self.storeRequestOnQueue(key: key, id: nil)
                                return
                            }

                            if let error = info?[PHImageErrorKey] as? Error {
                                if let fallbackResult = fallback.value {
                                    guardState.resumeOnce(continuation, returning: fallbackResult)
                                } else {
                                    guardState.resumeOnce(continuation, throwing: error)
                                }
                                self.storeRequestOnQueue(key: key, id: nil)
                                return
                            }

                            guard let image, let cgImage = Self.cgImage(from: image) else {
                                if let fallbackResult = fallback.value {
                                    guardState.resumeOnce(continuation, returning: fallbackResult)
                                } else {
                                    guardState.resumeOnce(
                                        continuation,
                                        throwing: InstagramPhotosImageLoadingError.imageUnavailable
                                    )
                                }
                                self.storeRequestOnQueue(key: key, id: nil)
                                return
                            }

                            let isDegraded = (info?[PHImageResultIsDegradedKey] as? Bool) ?? false
                            let result = (cgImage, info)
                            if isDegraded {
                                fallback.store(result)
                                if strategy.acceptsDegradedImage {
                                    guardState.resumeOnce(continuation, returning: result)
                                    self.storeRequestOnQueue(key: key, id: nil)
                                }
                            } else {
                                guardState.resumeOnce(continuation, returning: result)
                                self.storeRequestOnQueue(key: key, id: nil)
                            }
                        }
                    }

                    self.storeRequestOnQueue(key: key, id: requestID)
                }
            }
        } onCancel: { [weak self] in
            self?.cancel(for: key)
        }
    }

    private func requestImageData(
        key: String,
        asset: PHAsset,
        deliveryMode: PHImageRequestOptionsDeliveryMode,
        allowsNetwork: Bool,
        progress: (@Sendable (Double) -> Void)?
    ) async throws -> (Data, [AnyHashable: Any]?) {
        try Task.checkCancellation()

        return try await withTaskCancellationHandler {
            try await withCheckedThrowingContinuation { continuation in
                let guardState = ContinuationGuard()

                photoKitQueue.async { [weak self] in
                    guard let self else {
                        guardState.resumeOnce(continuation, throwing: InstagramPhotosImageLoadingError.cancelled)
                        return
                    }

                    self.cancelOnQueue(for: key)

                    let options = PHImageRequestOptions()
                    options.deliveryMode = deliveryMode
                    options.resizeMode = deliveryMode == .opportunistic ? .fast : .none
                    options.version = .current
                    options.isNetworkAccessAllowed = allowsNetwork
                    options.isSynchronous = false

                    if allowsNetwork, let progress {
                        options.progressHandler = { value, _, _, _ in
                            progress(value)
                        }
                    }

                    let requestID = self.imageManager.requestImageDataAndOrientation(
                        for: asset,
                        options: options
                    ) { data, _, _, info in
                        self.photoKitQueue.async {
                            self.storeRequestOnQueue(key: key, id: nil)

                            if let cancelled = info?[PHImageCancelledKey] as? Bool, cancelled {
                                guardState.resumeOnce(
                                    continuation,
                                    throwing: InstagramPhotosImageLoadingError.cancelled
                                )
                                return
                            }

                            if let error = info?[PHImageErrorKey] as? Error {
                                guardState.resumeOnce(continuation, throwing: error)
                                return
                            }

                            guard let data else {
                                guardState.resumeOnce(
                                    continuation,
                                    throwing: InstagramPhotosImageLoadingError.imageUnavailable
                                )
                                return
                            }

                            guardState.resumeOnce(continuation, returning: (data, info))
                        }
                    }

                    self.storeRequestOnQueue(key: key, id: requestID)
                }
            }
        } onCancel: { [weak self] in
            self?.cancel(for: key)
        }
    }

    private func cancelOnQueue(for key: String) {
        guard let requestID = activeRequests.removeValue(forKey: key) else { return }
        imageManager.cancelImageRequest(requestID)
    }

    private func cancelOnQueue(matching keyPrefix: String) {
        let keys = activeRequests.keys.filter { $0 == keyPrefix || $0.hasPrefix("\(keyPrefix)-") }
        for key in keys {
            cancelOnQueue(for: key)
        }
    }

    private func storeRequestOnQueue(key: String, id: PHImageRequestID?) {
        if let id {
            activeRequests[key] = id
        } else {
            activeRequests.removeValue(forKey: key)
        }
    }

    private func thumbnailOptions(allowsNetwork: Bool) -> PHImageRequestOptions {
        let options = PHImageRequestOptions()
        options.deliveryMode = .fastFormat
        options.resizeMode = .fast
        options.version = .current
        options.isNetworkAccessAllowed = allowsNetwork
        return options
    }

    private static func cgImage(from image: UIImage) -> CGImage? {
        UIImageCGImageBridge.cgImage(from: image)
    }

    #if DEBUG
    private func previewThumbnail(for asset: InstagramPhotosAsset) throws -> ImageLoadResult {
        let seed = PreviewColorSeed.value(for: asset.id)
        guard let cgImage = InstagramPhotosPreviewData.placeholderCGImage(seed: seed, size: 300) else {
            throw InstagramPhotosImageLoadingError.imageUnavailable
        }
        return ImageLoadResult(cgImage: cgImage, isInCloud: !asset.isLocallyAvailable)
    }

    private func previewFullSizeImage(
        for asset: InstagramPhotosAsset,
        progress: (@Sendable (Double) -> Void)?
    ) async throws -> CGImage {
        progress?(0.5)
        try await Task.sleep(nanoseconds: 200_000_000)
        let seed = PreviewColorSeed.value(for: asset.id)
        guard let cgImage = InstagramPhotosPreviewData.placeholderCGImage(seed: seed, size: 800) else {
            throw InstagramPhotosImageLoadingError.imageUnavailable
        }
        progress?(1)
        return cgImage
    }
    #endif
}

private final class ImageRequestFallback: @unchecked Sendable {
    private let lock = NSLock()
    private var stored: (CGImage, [AnyHashable: Any]?)?

    var value: (CGImage, [AnyHashable: Any]?)? {
        lock.lock()
        defer { lock.unlock() }
        return stored
    }

    func store(_ value: (CGImage, [AnyHashable: Any]?)) {
        lock.lock()
        defer { lock.unlock() }
        stored = value
    }
}

#if DEBUG
private enum PreviewColorSeed {
    static func value(for string: String) -> Int {
        var hasher = Hasher()
        hasher.combine(string)
        return hasher.finalize()
    }
}
#endif