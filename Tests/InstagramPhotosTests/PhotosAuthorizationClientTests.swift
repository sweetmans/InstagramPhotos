import XCTest
@testable import InstagramPhotos

final class PhotosAuthorizationClientTests: XCTestCase {
    func testCanBrowseLibraryOnlyForAuthorizedAndLimited() {
        XCTAssertFalse(InstagramPhotosAuthorizationStatus.denied.canBrowseLibrary)
        XCTAssertFalse(InstagramPhotosAuthorizationStatus.restricted.canBrowseLibrary)
        XCTAssertFalse(InstagramPhotosAuthorizationStatus.notDetermined.canBrowseLibrary)
        XCTAssertTrue(InstagramPhotosAuthorizationStatus.authorized.canBrowseLibrary)
        XCTAssertTrue(InstagramPhotosAuthorizationStatus.limited.canBrowseLibrary)
    }

    func testMockAuthorizationClientReturnsConfiguredStatus() async {
        let client = MockPhotosAuthorizationClient(status: .limited)
        XCTAssertEqual(client.currentStatus(), .limited)
        let requested = await client.requestAuthorization()
        XCTAssertEqual(requested, .limited)
    }
}

struct MockPhotosAuthorizationClient: PhotosAuthorizationClientProtocol {
    let status: InstagramPhotosAuthorizationStatus

    func currentStatus() -> InstagramPhotosAuthorizationStatus { status }

    func requestAuthorization() async -> InstagramPhotosAuthorizationStatus { status }
}