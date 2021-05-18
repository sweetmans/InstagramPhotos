//
//  Copyright © 2021年 Sweetman, Inc. All rights reserved.
//

import XCTest
@testable import InstagramPhotosPodspec

class InstagramPhotosPickingInteractorTests: XCTestCase {
    func test_showAlbumsView() {
        let viewController = InstagramPhotosPickingViewController(imagePicking: MockInstagramPhotosPicking())
        let albumsView = InstagramPhotosAlbumView.instance()
        let interactor = InstagramPhotosPickingInteractor(viewController: viewController, albumsView: albumsView)
        let expection = expectation(description: "test_showAlbumsView")
        interactor.showAlbumsView()
        expection.fulfill()
        waitForExpectations(timeout: 10, handler: nil)
        XCTAssertFalse(albumsView.navigationView.isHidden)
    }
}

final class MockInstagramPhotosPicking: InstagramPhotosPicking {
    func instagramPhotosDidFinishPickingImage(result: InstagramPhotosPickingResult) {}
}
