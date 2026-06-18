import CoreGraphics
import Foundation
import ImageIO

enum CGImageDecoding {
    static func decodeThumbnail(from data: Data, maxPixelSize: Int) -> CGImage? {
        guard let source = CGImageSourceCreateWithData(data as CFData, nil) else { return nil }
        let options: [CFString: Any] = [
            kCGImageSourceThumbnailMaxPixelSize: maxPixelSize,
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceCreateThumbnailWithTransform: true,
        ]
        return CGImageSourceCreateThumbnailAtIndex(source, 0, options as CFDictionary)
    }

    static func decodeFullSize(from data: Data) -> CGImage? {
        guard let source = CGImageSourceCreateWithData(data as CFData, nil) else { return nil }
        return CGImageSourceCreateImageAtIndex(source, 0, nil)
    }

    static func fittedSize(for image: CGImage, in target: CGSize) -> CGSize {
        let original = CGSize(width: image.width, height: image.height)
        if original.width > original.height {
            let scale = original.height / target.height
            return CGSize(width: original.width / scale, height: target.height)
        }
        let scale = original.width / target.width
        return CGSize(width: target.width, height: original.height / scale)
    }
}