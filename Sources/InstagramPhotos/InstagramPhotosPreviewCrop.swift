import CoreGraphics
import Foundation

/// Zoom and pan state from the picker's square preview region.
public struct InstagramPhotosPreviewCrop: Equatable, Sendable {
    public var offsetX: CGFloat
    public var offsetY: CGFloat
    public var scale: CGFloat
    public var previewSide: CGFloat

    public init(
        offsetX: CGFloat = 0,
        offsetY: CGFloat = 0,
        scale: CGFloat = 1,
        previewSide: CGFloat = 0
    ) {
        self.offsetX = offsetX
        self.offsetY = offsetY
        self.scale = Self.clampedScale(scale)
        self.previewSide = previewSide
    }

    public static let identity = InstagramPhotosPreviewCrop()

    public static let minimumScale: CGFloat = 1
    public static let maximumScale: CGFloat = 4

    public static func clampedScale(_ scale: CGFloat) -> CGFloat {
        min(max(scale, minimumScale), maximumScale)
    }

    /// Applies the preview crop to a full-size image using the same fill, zoom, and pan rules as the picker.
    public func squareCroppedImage(from image: CGImage) -> CGImage? {
        let width = CGFloat(image.width)
        let height = CGFloat(image.height)
        guard width > 0, height > 0, previewSide > 0 else { return nil }

        let clampedScale = Self.clampedScale(scale)
        let baseScale = max(previewSide / width, previewSide / height)
        let displayWidth = width * baseScale
        let displayHeight = height * baseScale
        let zoomedWidth = displayWidth * clampedScale
        let zoomedHeight = displayHeight * clampedScale
        let topLeftX = (previewSide - zoomedWidth) / 2 + offsetX
        let topLeftY = (previewSide - zoomedHeight) / 2 + offsetY
        let totalScale = baseScale * clampedScale

        var pixelX = -topLeftX / totalScale
        var pixelY = -topLeftY / totalScale
        var pixelSide = previewSide / totalScale

        pixelSide = min(pixelSide, min(width, height))
        pixelX = min(max(pixelX, 0), max(0, width - pixelSide))
        pixelY = min(max(pixelY, 0), max(0, height - pixelSide))

        let rect = CGRect(
            x: pixelX.rounded(.down),
            y: pixelY.rounded(.down),
            width: max(1, pixelSide.rounded(.down)),
            height: max(1, pixelSide.rounded(.down))
        )
        return image.cropping(to: rect)
    }
}