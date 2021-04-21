//
//  Copyright © 2021年 Sweetman, Inc. All rights reserved.
//

import UIKit
import Photos

public typealias InstagramImagePickingResult = Result<InstagramImage, InstagramImagePickingError>

public enum InstagramImagePickingError: Error {
    case unauthentication
    case generic(Error)
    case cancelByUser
    case downloadError
    case unknown
}

public protocol InstagramImagePicking {
    func instagramPhotosDidFinishPickingImage(result: InstagramImagePickingResult)
}

public protocol InstagramImage {
    var image: UIImage { get set }
    var metaData: [String: Any] { get set}
}

struct InstagramImageObject: InstagramImage {
    var image: UIImage
    var metaData: [String : Any]
}

let kDeviceScreenHeight = UIScreen.main.bounds.height
let kDeviceScreenWidth = UIScreen.main.bounds.width

public class InstagramImagePickingViewController: UIViewController {
    enum Strings: String {
        case viewControllerNibName = "InstagramImagePickingViewController"
        case initFatalError = "init(coder:) has not been implemented"
    }
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    
    private let albumView = SMPhotoPickerAlbumView.instance()
    let library: SMPhotoPickerLibraryView = SMPhotoPickerLibraryView.instance()
    
    private let imagePicking: InstagramImagePicking
    private var albumsProvider: InstagramImageAlbumsProviding
    
    public init(imagePicking: InstagramImagePicking,
                albumsProvider: InstagramImageAlbumsProviding = InstagramImageAlbumsProvider()) {
        self.imagePicking = imagePicking
        self.albumsProvider = albumsProvider
        super.init(nibName: Strings.viewControllerNibName.rawValue, bundle: Bundle(for: InstagramImagePickingViewController.classForCoder()))
    }
    
    required init?(coder: NSCoder) {
        fatalError(Strings.initFatalError.rawValue)
    }
    
    //override public var prefersStatusBarHidden : Bool { return true }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        getAuthorizationStatue { (auth) in
            if !auth {
                print("User can not assecc photolibrary.")
                return
            }
        }
        settingLibraryView()
        settingAlbumsView()
    }
    
    private func settingLibraryView() {
        library.frame = CGRect(origin: CGPoint.zero, size: scrollView.frame.size)
        let interactor = InstagramImagePickingInteractor(albumsView: albumView)
        library.pickingInteractor = interactor
        library.collectionView.reloadData()
        scrollView.addSubview(library)
    }
    
    private func settingAlbumsView() {
        albumView.delegate = self
        let interactor = InstagramImagePickingInteractor(albumsView: albumView)
        albumView.pickingInteractor = interactor
        albumView.frame = CGRect(x: 0, y: kDeviceScreenHeight, width: kDeviceScreenWidth, height: kDeviceScreenHeight)
        view.addSubview(self.albumView)
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        view.frame = UIScreen.main.bounds
    }
    
    func showAlbums(showing: Bool) {
        if showing {
            UIView.animate(withDuration: 1,
                           delay: 0.3,
                           usingSpringWithDamping: 12,
                           initialSpringVelocity: 12,
                           options: .layoutSubviews,
                           animations: {
                            self.albumView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height - 44.0)
                           }) { _ in }
        }else {
            UIView.animate(withDuration: 0.3, animations: {
                self.albumView.frame = CGRect(x: 0, y: self.view.frame.height, width: self.view.frame.width, height: self.view.frame.height - 44.0)
            })
        }
    }
    
    func next() {
        if library.isOnDownloadingImage {
            let alert = UIAlertController.init(title: "Photo is downloading", message: "Please wait.", preferredStyle: .alert)
            let cancel = UIAlertAction.init(title: "Got it.", style: .cancel, handler: { _ in})
            alert.addAction(cancel)
            self.present(alert, animated: true, completion: nil)
        }else{
            guard let image = library.imageView.image,
                  let asset =  library.currentAsset else {
                imagePicking.instagramPhotosDidFinishPickingImage(result: .failure(.unknown))
                return
            }
            let cropedimage = image.crop(rect: library.scaleRect, scale: library.imageScale / library.scale)
            var mateData: [String: Any] = [String: Any]()
            mateData["mediaType"] = asset.mediaType
            mateData["mediaSubtypes"] = asset.mediaSubtypes
            mateData["size"] = CGSize(width: asset.pixelWidth, height: asset.pixelHeight)
            mateData["creationTimestamp"] = Int(asset.creationDate?.timeIntervalSince1970 ?? 0)
            mateData["location"] = asset.location
            mateData["sourceType"] = asset.sourceType
            
            let ipImage = InstagramImageObject(image: cropedimage, metaData: mateData)
            imagePicking.instagramPhotosDidFinishPickingImage(result: .success(ipImage))
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    func cancel() {
        imagePicking.instagramPhotosDidFinishPickingImage(result: .failure(.cancelByUser))
        dismiss(animated: true, completion: nil)
    }
    
    func getAuthorizationStatue(result: @escaping (Bool) -> Void) {
        if #available(iOS 14, *) {
            if PHPhotoLibrary.authorizationStatus() != .authorized || PHPhotoLibrary.authorizationStatus() != .limited {
                requestAuthorization(result: result)
            } else {
                result(true)
            }
        } else {
            if PHPhotoLibrary.authorizationStatus() != .authorized {
                requestAuthorization(result: result)
            } else {
                result(true)
            }
        }
    }
    
    private func requestAuthorization(result: @escaping (Bool) -> Void) {
        PHPhotoLibrary.requestAuthorization({ (status) in
            if #available(iOS 14, *) {
                if status == .authorized || status == .limited {
                    result(true)
                }else{
                    result(false)
                }
            } else {
                if status == .authorized {
                    result(true)
                }else{
                    result(false)
                }
            }
        })
    }
}

extension InstagramImagePickingViewController {
    @IBAction func closeButtonAction(_ sender: UIButton) {
        cancel()
    }
    
    @IBAction func nextButtonAction(_ sender: UIButton) {
        next()
    }
}

extension InstagramImagePickingViewController: SMPhotoPickerAlbumViewDelegate {
    func didSeletctAlbum(album: InstagramImageAlbum) {
        library.images = album.assets
        library.collectionView.reloadData()
        library.collectionView.selectItem(at: IndexPath.init(row: 0, section: 0), animated: false, scrollPosition: .bottom)
        library.updateShowAlbumButton(title: album.name)
        loadingAlbumFirstImage(album: album)
        UIView.animate(withDuration: 0.3, animations: {
            self.albumView.frame = CGRect(x: 0, y: kDeviceScreenHeight, width: kDeviceScreenWidth, height: kDeviceScreenHeight)
        })
    }
    
    private func loadingAlbumFirstImage(album: InstagramImageAlbum) {
        guard let firstAsset = albumsProvider.fetchAlbumFirstAsset(collection: album.collection) else { return }
        albumsProvider.fetchAssetImage(asset: firstAsset, size: .original) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let image):
                self.library.setupFirstLoadingImageAttrabute(image: image)
            default:
                print("Selected ablum loading first image failure")
            }
        }
    }
}
