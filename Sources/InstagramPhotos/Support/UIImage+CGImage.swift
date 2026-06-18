#if canImport(UIKit)
import CoreGraphics
import UIKit

enum UIImageCGImageBridge {
    static func cgImage(from image: UIImage) -> CGImage? {
        if let cgImage = image.cgImage {
            return cgImage
        }

        if let ciImage = image.ciImage {
            let context = CIContext(options: nil)
            return context.createCGImage(ciImage, from: ciImage.extent)
        }

        let format = UIGraphicsImageRendererFormat()
        format.scale = image.scale
        let renderer = UIGraphicsImageRenderer(size: image.size, format: format)
        return renderer.image { _ in
            image.draw(at: .zero)
        }.cgImage
    }
}
#endif