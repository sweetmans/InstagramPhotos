import Foundation

/// Assets and preview crop state returned when the picker finishes.
public struct InstagramPhotosPickerFinishResult: Equatable, Sendable {
    public let assets: [InstagramPhotosAsset]
    public let previewCrop: InstagramPhotosPreviewCrop

    public init(
        assets: [InstagramPhotosAsset],
        previewCrop: InstagramPhotosPreviewCrop
    ) {
        self.assets = assets
        self.previewCrop = previewCrop
    }
}