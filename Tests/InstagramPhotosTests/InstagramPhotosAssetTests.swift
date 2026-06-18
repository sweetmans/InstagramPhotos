import XCTest
@testable import InstagramPhotos

final class InstagramPhotosAssetTests: XCTestCase {
    func testEqualityUsesIdentifier() {
        let lhs = InstagramPhotosAsset(
            id: "asset-1",
            mediaType: .image,
            pixelWidth: 10,
            pixelHeight: 20,
            creationDate: nil,
            isLocallyAvailable: false
        )
        let rhs = InstagramPhotosAsset(
            id: "asset-1",
            mediaType: .video,
            pixelWidth: 99,
            pixelHeight: 99,
            creationDate: Date(),
            isLocallyAvailable: true
        )

        XCTAssertEqual(lhs, rhs)
    }

    func testHashableUsesIdentifier() {
        let asset = InstagramPhotosAsset(
            id: "asset-1",
            mediaType: .image,
            pixelWidth: 1,
            pixelHeight: 1,
            creationDate: nil,
            isLocallyAvailable: true
        )
        var set = Set<InstagramPhotosAsset>()
        set.insert(asset)
        XCTAssertEqual(set.count, 1)
    }
}