//
//  Copyright © 2021年 Sweetman, Inc. All rights reserved.
//

import Foundation
import UIKit

protocol InstagramImagePickingInteracting {
    func showAlbumsView()
    func hidnAlbumsView()
}

struct InstagramImagePickingInteractor: InstagramImagePickingInteracting {
    private let deviceScreenHeight = UIScreen.main.bounds.height
    private let deviceScreenWidth = UIScreen.main.bounds.width
    private let albumsView: SMPhotoPickerAlbumView
    
    init(albumsView: SMPhotoPickerAlbumView) {
        self.albumsView = albumsView
    }
    
    func showAlbumsView() {
        albumsView.navigationView.isHidden = true
        UIView.animate(withDuration: 0.32,
                       delay: 0.0,
                       usingSpringWithDamping: 320,
                       initialSpringVelocity: 16,
                       options: .layoutSubviews,
                       animations: {
                        albumsView.frame = CGRect(x: 0, y: 0, width: deviceScreenWidth, height: deviceScreenHeight)
                       }) { _ in
            albumsView.navigationView.isHidden = false
        }
    }
    
    func hidnAlbumsView() {
        UIView.animate(withDuration: 0.32,
                       delay: 0.0,
                       usingSpringWithDamping: 320,
                       initialSpringVelocity: 16,
                       options: .layoutSubviews,
                       animations: {
                        albumsView.frame = CGRect(x: 0, y: deviceScreenHeight, width: deviceScreenWidth, height: deviceScreenHeight)
                       }) { _ in
            albumsView.navigationView.isHidden = true
        }
    }
}


