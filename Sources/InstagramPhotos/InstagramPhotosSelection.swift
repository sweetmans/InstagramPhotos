import Foundation

/// Observable selection state for the photo picker.
@MainActor
public final class InstagramPhotosSelection: ObservableObject {
    @Published public private(set) var assets: [InstagramPhotosAsset]
    @Published public private(set) var focusedAsset: InstagramPhotosAsset?
    @Published public private(set) var allowsMultipleSelection: Bool
    @Published public private(set) var previewCrop = InstagramPhotosPreviewCrop.identity

    private var configuration: InstagramPhotosPickerConfiguration

    public init(
        assets: [InstagramPhotosAsset] = [],
        configuration: InstagramPhotosPickerConfiguration = .init()
    ) {
        self.assets = assets
        self.focusedAsset = assets.first
        self.configuration = configuration
        self.allowsMultipleSelection = configuration.allowsMultipleSelection
    }

    public var isEmpty: Bool { assets.isEmpty }

    public var count: Int { assets.count }

    public var isAtLimit: Bool {
        !configuration.canSelectAdditional(count: assets.count)
    }

    public func contains(_ asset: InstagramPhotosAsset) -> Bool {
        assets.contains(asset)
    }

    public func selectionIndex(for asset: InstagramPhotosAsset) -> Int? {
        assets.firstIndex(of: asset)
    }

    public func toggle(_ asset: InstagramPhotosAsset) {
        if let index = assets.firstIndex(of: asset) {
            assets.remove(at: index)
            if focusedAsset == asset {
                focusedAsset = assets.first
            }
        } else if configuration.canSelectAdditional(count: assets.count) {
            assets.append(asset)
            focusedAsset = asset
        } else if !configuration.allowsMultipleSelection {
            assets = [asset]
            focusedAsset = asset
        }
    }

    public func focus(_ asset: InstagramPhotosAsset) {
        focusedAsset = asset
        if configuration.allowsMultipleSelection, !assets.contains(asset) {
            if configuration.canSelectAdditional(count: assets.count) {
                assets.append(asset)
            }
        } else if !configuration.allowsMultipleSelection {
            assets = [asset]
        }
    }

    public func replaceAll(with newAssets: [InstagramPhotosAsset]) {
        let limit = configuration.effectiveSelectionLimit
        assets = Array(newAssets.prefix(limit))
        focusedAsset = assets.first
    }

    public func clear() {
        assets = []
        focusedAsset = nil
        resetPreviewCrop()
    }

    public func updatePreviewCrop(
        offsetX: CGFloat,
        offsetY: CGFloat,
        scale: CGFloat,
        previewSide: CGFloat
    ) {
        previewCrop = InstagramPhotosPreviewCrop(
            offsetX: offsetX,
            offsetY: offsetY,
            scale: scale,
            previewSide: previewSide
        )
    }

    public func resetPreviewCrop() {
        previewCrop = .identity
    }

    public func setAllowsMultipleSelection(_ allowed: Bool) {
        guard allowsMultipleSelection != allowed else { return }
        allowsMultipleSelection = allowed
        configuration.allowsMultipleSelection = allowed

        if !allowed, assets.count > 1 {
            let kept = focusedAsset ?? assets.first
            if let kept {
                assets = [kept]
                focusedAsset = kept
            } else {
                assets = []
                focusedAsset = nil
            }
        } else if allowed {
            let limit = configuration.effectiveSelectionLimit
            if limit != .max, assets.count > limit {
                assets = Array(assets.prefix(limit))
                focusedAsset = assets.first
            }
        }
    }
}