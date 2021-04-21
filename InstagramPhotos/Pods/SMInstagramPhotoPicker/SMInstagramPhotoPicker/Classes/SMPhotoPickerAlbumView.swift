//
//  Copyright © 2021年 Sweetman, Inc. All rights reserved.
//

import UIKit

protocol SMPhotoPickerAlbumViewDelegate {
    func didSeletctAlbum(album: InstagramImageAlbum)
}

class SMPhotoPickerAlbumView: UIView {
    private let albumNibName = "SMPhotoPickAlbumViewCell"
    private let albumCellReuseIdentifier = "SMPhotoPickerAlbumView"
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var navigationView: UIView!
    @IBOutlet weak var cancelButton: UIButton!
    
    let albums: [InstagramImageAlbum] = InstagramImageAlbumsProvider().listAllAlbums()
    var delegate: SMPhotoPickerAlbumViewDelegate? = nil
    var pickingInteractor: InstagramImagePickingInteracting?
    
    static func instance() -> SMPhotoPickerAlbumView {
        let view = UINib(nibName: "SMPhotoPickerAlbumView", bundle: Bundle(for: self.classForCoder())).instantiate(withOwner: self, options: nil)[0] as! SMPhotoPickerAlbumView
        view.initialize()
        return view
    }
    
    
    func initialize() {
        tableView.register(UINib(nibName: albumNibName, bundle: Bundle(for: self.classForCoder)), forCellReuseIdentifier: albumCellReuseIdentifier)
    }
}

extension SMPhotoPickerAlbumView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: albumCellReuseIdentifier, for: indexPath) as! SMPhotoPickAlbumViewCell
        cell.album = albums[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return albums.count > 0 ? albums.count : 0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 96.0
    }
}

extension SMPhotoPickerAlbumView {
    @IBAction func cancelButtonAction(_ sender: UIButton) {
        guard let interactor = pickingInteractor else { return }
        interactor.hidnAlbumsView()
    }
}

extension SMPhotoPickerAlbumView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.didSeletctAlbum(album: albums[indexPath.row])
    }
}










