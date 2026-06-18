import CoreGraphics

extension CGImage {
    func cropped(to rect: CGRect, imageScale: CGFloat, additionalScale: CGFloat = 1) -> CGImage? {
        var cropRect = rect
        cropRect.origin.x *= imageScale
        cropRect.origin.y *= imageScale
        cropRect.size.width *= imageScale
        cropRect.size.height *= imageScale

        cropRect.origin.x *= additionalScale
        cropRect.origin.y *= additionalScale
        cropRect.size.width *= additionalScale
        cropRect.size.height *= additionalScale

        return cropping(to: cropRect)
    }
}