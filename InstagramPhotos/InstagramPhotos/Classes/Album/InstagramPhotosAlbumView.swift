//
//  Copyright © 2021年 Sweetman, Inc. All rights reserved.
//

import UIKit

protocol InstagramPhotosAlbumViewDelegate {
    func didSeletctAlbum(album: InstagramPhotosAlbum)
}

public class InstagramPhotosAlbumView: UIView {
    private let albumNibName = "InstagramPhotosAlbumViewCell"
    private let albumCellReuseIdentifier = "InstagramPhotosAlbumView"
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var navigationView: UIView!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var navigationTitleButton: UIButton!
    
    let albums: [InstagramPhotosAlbum] = InstagramPhotosAlbumsProvider().listAllAlbums()
    var delegate: InstagramPhotosAlbumViewDelegate? = nil
    var pickingInteractor: InstagramPhotosPickingInteracting?
    
    public static func instance() -> InstagramPhotosAlbumView {
        let view = UINib(nibName: "InstagramPhotosAlbumView",
                         bundle: Bundle(for: InstagramPhotosAlbumView.classForCoder())).instantiate(withOwner: self, options: nil)[0] as! InstagramPhotosAlbumView
        view.initialize()
        InstagramPhotosLocalizationManager.main.addLocalizationConponent(localizationUpdateable: view)
        return view
    }
    
    private func initialize() {
        tableView.register(UINib(nibName: albumNibName,
                                 bundle: Bundle(for: InstagramPhotosAlbumView.classForCoder())),
                           forCellReuseIdentifier: albumCellReuseIdentifier)
    }
}

extension InstagramPhotosAlbumView: InstagramPhotosLocalizationUpdateable {
    public func localizationContents() {
        let provider = InstagramPhotosLocalizationManager.main.localizationsProviding
        cancelButton.setTitle(provider.albumControllerNavigationCancelButtonText(), for: .normal)
        navigationTitleButton.setTitle(provider.albumControllerNavigationTitle(), for: .normal)
    }
}

extension InstagramPhotosAlbumView: UITableViewDataSource {
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: albumCellReuseIdentifier, for: indexPath) as! InstagramPhotosAlbumViewCell
        cell.album = albums[indexPath.row]
        return cell
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return albums.count > 0 ? albums.count : 0
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 96.0
    }
}

extension InstagramPhotosAlbumView {
    @IBAction func cancelButtonAction(_ sender: UIButton) {
        guard let interactor = pickingInteractor else { return }
        interactor.hidnAlbumsView()
    }
}

extension InstagramPhotosAlbumView: UITableViewDelegate {
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.didSeletctAlbum(album: albums[indexPath.row])
    }
}
