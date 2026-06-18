import CoreGraphics
import SwiftUI

struct PhotoPreviewView: View {
    let asset: InstagramPhotosAsset?
    var layoutSide: CGFloat?
    let configuration: InstagramPhotosPickerConfiguration
    let imageLoader: ImageLoadingClient
    let onPreviewCropChanged: (InstagramPhotosPreviewCrop) -> Void

    @State private var previewImage: CGImage?
    @State private var downloadProgress: Double = 0
    @State private var isDownloading = false
    @State private var loadTask: Task<Void, Never>?
    @State private var zoomScale: CGFloat = 1
    @State private var lastZoomScale: CGFloat = 1
    @State private var contentOffset = CGSize.zero
    @State private var lastContentOffset = CGSize.zero
    @State private var showsCropMask = false
    @State private var previewSide: CGFloat = 0
    @State private var loadedAssetID: String?

    var body: some View {
        Group {
            if let layoutSide, layoutSide > 0 {
                previewContent(side: layoutSide)
            } else {
                GeometryReader { geometry in
                    previewContent(side: min(geometry.size.width, geometry.size.height))
                }
                .aspectRatio(1, contentMode: .fit)
            }
        }
        .onDisappear {
            loadTask?.cancel()
            loadTask = nil
        }
    }

    @ViewBuilder
    private func previewContent(side: CGFloat) -> some View {
        let previewSize = CGSize(width: side, height: side)

        ZStack {
            PickerDesign.previewBackground

            if let previewImage {
                ZoomableSwiftUIImage(
                    cgImage: previewImage,
                    previewSize: previewSize,
                    zoomScale: $zoomScale,
                    lastZoomScale: $lastZoomScale,
                    contentOffset: $contentOffset,
                    lastContentOffset: $lastContentOffset,
                    isInteracting: $showsCropMask,
                    onCropChanged: publishPreviewCrop
                )
            } else {
                ProgressView()
                    .controlSize(.regular)
            }

            if showsCropMask {
                Rectangle()
                    .strokeBorder(Color.primary.opacity(0.2), lineWidth: 1)
                    .allowsHitTesting(false)
            }

            if configuration.showsProgress, isDownloading {
                LoadingProgressView(
                    progress: downloadProgress,
                    label: configuration.localizationProvider.iCloudDownloadingText()
                )
            }
        }
        .frame(width: previewSize.width, height: previewSize.height)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .clipped()
        .transaction { transaction in
            transaction.animation = nil
        }
        .onAppear {
            updatePreviewSideIfNeeded(side)
        }
        .onChange(of: side) { newSide in
            updatePreviewSideIfNeeded(newSide)
        }
    }

    private func updatePreviewSideIfNeeded(_ side: CGFloat) {
        guard side > 0 else { return }
        guard abs(side - previewSide) > 1 else { return }

        previewSide = side
        publishPreviewCrop()
        reloadImage(using: side)
    }

    private func publishPreviewCrop() {
        onPreviewCropChanged(
            InstagramPhotosPreviewCrop(
                offsetX: contentOffset.width,
                offsetY: contentOffset.height,
                scale: zoomScale,
                previewSide: previewSide
            )
        )
    }

    private func reloadImage(using side: CGFloat?) {
        guard let asset else {
            loadTask?.cancel()
            previewImage = nil
            loadedAssetID = nil
            return
        }

        if loadedAssetID == asset.id, previewImage != nil {
            return
        }

        loadTask?.cancel()
        if loadedAssetID != asset.id {
            previewImage = nil
        }
        downloadProgress = 0
        isDownloading = false
        zoomScale = 1
        lastZoomScale = 1
        contentOffset = .zero
        lastContentOffset = .zero
        publishPreviewCrop()

        let resolvedSide = max(side ?? previewSide, 320)
        let previewPointSize = CGSize(
            width: resolvedSide * PickerDesign.previewZoomHeadroom,
            height: resolvedSide * PickerDesign.previewZoomHeadroom
        )
        let allowsNetwork = configuration.iCloudNetworkAccessAllowed
        let gridCacheKey = ImageCacheKey.thumbnail(
            assetID: asset.id,
            targetSize: configuration.thumbnailSize
        )

        loadTask = Task {
            var cached = await ImageCache.shared.image(for: gridCacheKey)
            if cached == nil {
                cached = await ImageCache.shared.imageForAssetID(asset.id)
            }
            if let cached {
                guard !Task.isCancelled else { return }
                await applyPreviewImage(cached, assetID: asset.id)
            }

            await imageLoader.ensurePrepared(assetID: asset.id)

            do {
                let result = try await imageLoader.loadPreviewImage(
                    for: asset,
                    targetSize: previewPointSize,
                    allowsNetwork: allowsNetwork
                )

                guard !Task.isCancelled else { return }
                await applyPreviewImage(result.cgImage, assetID: asset.id)

                let cacheKey = ImageCacheKey.thumbnail(assetID: asset.id, targetSize: previewPointSize)
                await ImageCache.shared.insert(result.cgImage, for: cacheKey, assetID: asset.id)

                guard needsFullSizeUpgrade(result: result, asset: asset, allowsNetwork: allowsNetwork) else {
                    await MainActor.run { isDownloading = false }
                    return
                }

                await MainActor.run {
                    isDownloading = result.isInCloud && allowsNetwork
                }

                let fullImage = try await imageLoader.loadFullSizeImage(for: asset) { progress in
                    Task { @MainActor in
                        downloadProgress = progress
                        isDownloading = true
                    }
                }

                guard !Task.isCancelled else { return }
                await applyPreviewImage(fullImage, assetID: asset.id)
                await MainActor.run {
                    isDownloading = false
                    downloadProgress = 0
                }
            } catch {
                await loadFullSizeFallback(for: asset, allowsNetwork: allowsNetwork)
            }
        }
    }

    @MainActor
    private func applyPreviewImage(_ image: CGImage, assetID: String) {
        previewImage = image
        loadedAssetID = assetID
    }

    private func needsFullSizeUpgrade(
        result: ImageLoadResult,
        asset: InstagramPhotosAsset,
        allowsNetwork: Bool
    ) -> Bool {
        if result.isInCloud, allowsNetwork {
            return true
        }

        let loadedMaxSide = max(result.cgImage.width, result.cgImage.height)
        let assetMaxSide = max(asset.pixelWidth, asset.pixelHeight)
        return loadedMaxSide < assetMaxSide / 2
    }

    private func loadFullSizeFallback(for asset: InstagramPhotosAsset, allowsNetwork: Bool) async {
        guard !Task.isCancelled else { return }

        do {
            await MainActor.run {
                isDownloading = asset.isLocallyAvailable == false && allowsNetwork
            }

            let fullImage = try await imageLoader.loadFullSizeImage(for: asset) { progress in
                Task { @MainActor in
                    downloadProgress = progress
                    isDownloading = true
                }
            }

            guard !Task.isCancelled else { return }
            await applyPreviewImage(fullImage, assetID: asset.id)
            await MainActor.run {
                isDownloading = false
                downloadProgress = 0
            }
        } catch {
            await MainActor.run {
                if previewImage == nil {
                    loadedAssetID = nil
                }
                isDownloading = false
            }
        }
    }
}

private struct ZoomableSwiftUIImage: View {
    let cgImage: CGImage
    let previewSize: CGSize
    @Binding var zoomScale: CGFloat
    @Binding var lastZoomScale: CGFloat
    @Binding var contentOffset: CGSize
    @Binding var lastContentOffset: CGSize
    @Binding var isInteracting: Bool
    let onCropChanged: () -> Void

    var body: some View {
        Image(decorative: cgImage, scale: 1, orientation: .up)
            .resizable()
            .scaledToFill()
            .frame(width: previewSize.width, height: previewSize.height)
            .scaleEffect(zoomScale)
            .offset(contentOffset)
            .frame(width: previewSize.width, height: previewSize.height)
            .clipped()
            .contentShape(Rectangle())
            .gesture(dragGesture)
            .simultaneousGesture(zoomGesture)
    }

    private var dragGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                isInteracting = true
                contentOffset = CGSize(
                    width: lastContentOffset.width + value.translation.width,
                    height: lastContentOffset.height + value.translation.height
                )
                onCropChanged()
            }
            .onEnded { _ in
                isInteracting = false
                lastContentOffset = contentOffset
                onCropChanged()
            }
    }

    private var zoomGesture: some Gesture {
        MagnificationGesture()
            .onChanged { value in
                isInteracting = true
                zoomScale = min(max(lastZoomScale * value, 1), 4)
                onCropChanged()
            }
            .onEnded { _ in
                isInteracting = false
                lastZoomScale = zoomScale
                onCropChanged()
            }
    }
}

#if DEBUG
#Preview("Focused Asset") {
    InstagramPhotosPreviewHostFactory.photoPreview()
}

#Preview("No Asset") {
    InstagramPhotosPreviewHostFactory.photoPreview(asset: nil)
}

#Preview("iCloud Download") {
    PhotoPreviewView(
        asset: InstagramPhotosPreviewData.assets.first { !$0.isLocallyAvailable },
        configuration: InstagramPhotosPreviewData.configuration,
        imageLoader: ImageLoadingClient.preview,
        onPreviewCropChanged: { _ in }
    )
}
#endif