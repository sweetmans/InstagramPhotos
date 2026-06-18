import CoreGraphics
import XCTest
@testable import InstagramPhotos

final class InstagramPhotosPreviewCropTests: XCTestCase {
    func testSquareCroppedImageReturnsSquareOutput() {
        guard let source = makeTestImage(width: 400, height: 200) else {
            XCTFail("Expected test image")
            return
        }

        let crop = InstagramPhotosPreviewCrop(
            offsetX: 0,
            offsetY: 0,
            scale: 1,
            previewSide: 200
        )
        let cropped = crop.squareCroppedImage(from: source)

        XCTAssertNotNil(cropped)
        XCTAssertEqual(cropped?.width, cropped?.height)
    }

    func testSelectionStoresPreviewCrop() {
        let selection = InstagramPhotosSelection()
        selection.updatePreviewCrop(offsetX: 12, offsetY: -8, scale: 1.5, previewSide: 320)

        XCTAssertEqual(selection.previewCrop.offsetX, 12)
        XCTAssertEqual(selection.previewCrop.offsetY, -8)
        XCTAssertEqual(selection.previewCrop.scale, 1.5)
        XCTAssertEqual(selection.previewCrop.previewSide, 320)
    }

    private func makeTestImage(width: Int, height: Int) -> CGImage? {
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        guard let context = CGContext(
            data: nil,
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: 0,
            space: colorSpace,
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        ) else {
            return nil
        }
        context.setFillColor(CGColor(red: 0.2, green: 0.4, blue: 0.9, alpha: 1))
        context.fill(CGRect(x: 0, y: 0, width: width, height: height))
        return context.makeImage()
    }
}