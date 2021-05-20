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
        interactor.showAlbumsView()
        XCTAssertTrue(albumsView.navigationView.isHidden)
    }
    
    func test_hidnAlbumsView() {
        let viewController = InstagramPhotosPickingViewController(imagePicking: MockInstagramPhotosPicking())
        let albumsView = InstagramPhotosAlbumView.instance()
        let interactor = InstagramPhotosPickingInteractor(viewController: viewController, albumsView: albumsView)
        interactor.hidnAlbumsView()
        XCTAssertFalse(albumsView.navigationView.isHidden)
    }
    
    func test_presentLimitedLibraryPicker() {
        let viewController = InstagramPhotosPickingViewController(imagePicking: MockInstagramPhotosPicking())
        let albumsView = InstagramPhotosAlbumView.instance()
        let interactor = InstagramPhotosPickingInteractor(viewController: viewController, albumsView: albumsView)
        interactor.presentLimitedLibraryPicker()
    }
}

final class MockInstagramPhotosPicking: InstagramPhotosPicking {
    func instagramPhotosDidFinishPickingImage(result: InstagramPhotosPickingResult) {}
}
