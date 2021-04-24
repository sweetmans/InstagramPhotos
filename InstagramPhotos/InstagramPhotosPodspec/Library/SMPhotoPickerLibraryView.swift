//
//  Copyright © 2021年 Sweetman, Inc. All rights reserved.
//

import UIKit
import Photos

public class SMPhotoPickerLibraryView: UIView {
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var showAlbumsButton: UIButton!
    @IBOutlet weak var squareMask: UIImageView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var addingMoreImageVisualView: UIVisualEffectView!
    @IBOutlet weak var progressView: SMProgressView!
    
    lazy var imageView: UIImageView = {
        let i = UIImageView()
        i.contentMode = .scaleAspectFill
        i.clipsToBounds = true
        return i
    }()
    
    var currentAsset: PHAsset?
    var currentImageRequestID: PHImageRequestID?
    var isOnDownloadingImage: Bool = true
    
    let cellSize = CGSize(width: 300, height: 300)
    var images: PHFetchResult<PHAsset>!
    var imageManager: PHCachingImageManager?
    var phAsset: PHAsset!
    
    var scale: CGFloat = 1.0
    var scaleRect: CGRect = CGRect.zero
    var imageScale: CGFloat = 1.0
    
    var pickingInteractor: InstagramImagePickingInteracting?
    private let albumsProvider: InstagramImageAlbumsProviding = InstagramImageAlbumsProvider()
    
    public static func instance() -> SMPhotoPickerLibraryView {
        let view = UINib(nibName: "SMPhotoPickerLibraryView", bundle: Bundle(for: self.classForCoder())).instantiate(withOwner: self, options: nil)[0] as! SMPhotoPickerLibraryView
        view.initialize()
        InstagramPhotosLocalizationManager.main.addLocalizationConponent(localizationUpdateable: view)
        return view
    }
    
    func initialize() {
        if images != nil { return }
        settingFirstAlbum()
        scrollView.addSubview(imageView)
        imageView.frame = scrollView.frame
        collectionView.register(UINib(nibName: "SMPhotoPickerImageCell", bundle: Bundle(for: self.classForCoder)), forCellWithReuseIdentifier: "SMPhotoPickerImageCell")
        
        addingMoreImageVisualView.clipsToBounds = true
        addingMoreImageVisualView.layer.cornerRadius = 23
        collectionView.selectItem(at: IndexPath.init(row: 0, section: 0), animated: false, scrollPosition: .bottom)
        if InstagramPhotosAuthorizationProvider().authorizationStatus() != .limited {
            addingMoreImageVisualView.isHidden = true
        }
    }
    
    func settingFirstAlbum() {
        guard let firstAlbum = InstagramImageAlbumsProvider().listAllAlbums().first else { return }
        images = firstAlbum.assets
        currentAsset = firstAlbum.assets.firstObject
        loadingAlbumFirstImage(album: firstAlbum)
    }
    
    func setupFirstLoadingImageAttrabute(image: UIImage) {
        self.imageView.image = image
        let se = self.cacuclateContentSize(original: image.size, target: self.scrollView.frame.size)
        self.scrollView.contentSize = se
        self.imageView.frame = CGRect(origin: CGPoint.zero, size: se)
        self.scaleRect = CGRect(origin: CGPoint.zero, size: scrollView.frame.size)
        self.scrollView.zoomScale = 1.0
        self.scale = 1.0
    }
    
    func cacuclateContentSize(original: CGSize, target: CGSize) -> CGSize {
        var size = CGSize(width: 0, height: 0)
        if original.width > original.height {
            let scale = original.height / target.height
            let w = original.width / scale
            self.imageScale = scale
            size = CGSize(width: w, height: target.height)
        }else{
            let scale = original.width / target.width
            let w = original.height / scale
            self.imageScale = scale
            size = CGSize(width: target.width, height: w)
        }
        return size
    }
    
    func updateShowAlbumButton(title: String) {
        showAlbumsButton.setTitle(title, for: .normal)
    }
    
    private func loadingAlbumFirstImage(album: InstagramImageAlbum) {
        guard let firstAsset = albumsProvider.fetchAlbumFirstAsset(collection: album.collection) else { return }
        albumsProvider.fetchAssetImage(asset: firstAsset, size: .original) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let image):
                self.setupFirstLoadingImageAttrabute(image: image)
            default:
                print("Selected ablum loading first image failure")
            }
        }
    }
}

extension SMPhotoPickerLibraryView: InstagramPhotosLocalizationUpdateable {
    public func localizationContents() {
        let provider = InstagramPhotosLocalizationManager.main.localizationsProviding
        showAlbumsButton.setTitle(provider.pinkingControllerDefaultAlbumName(), for: .normal)
    }
}

extension SMPhotoPickerLibraryView {
    @IBAction func showAlbumsButtonAction(_ sender: Any) {
        guard let interactor = pickingInteractor else { return }
        interactor.showAlbumsView()
    }
}

extension SMPhotoPickerLibraryView: UICollectionViewDelegate, UICollectionViewDataSource, UIScrollViewDelegate, UICollectionViewDelegateFlowLayout {
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SMPhotoPickerImageCell", for: indexPath) as! SMPhotoPickerImageCell
        let asset = self.images[(indexPath as NSIndexPath).item]
        PHImageManager.default().requestImage(for: asset, targetSize: cellSize, contentMode: .aspectFill, options: nil) { (image, info) in
            cell.image = image
        }
        return cell
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images == nil ? 0 : images.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (UIScreen.main.bounds.width - 3) / 4.00
        return CGSize(width: width, height: width)
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let asset = images[(indexPath as NSIndexPath).row]
        currentAsset = asset
        isOnDownloadingImage = true
        
        let targetSize = CGSize(width: asset.pixelWidth, height: asset.pixelHeight)
        //print(asset.sourceType)
        if currentImageRequestID != nil {
            //print("cancel loading image from icloud. ID:\(self.currentImageRequestID!)")
            PHImageManager.default().cancelImageRequest(self.currentImageRequestID!)
        }
        
        progressView.isHidden = true
        let requestOptions = PHImageRequestOptions()
        requestOptions.isNetworkAccessAllowed = true
        requestOptions.version = .original
        requestOptions.progressHandler = {  [weak self] progress, err, pointer, info in
            guard let self = self else { return }
            DispatchQueue.main.async {
                if self.progressView.isHidden {
                    self.progressView.isHidden = false
                }
                self.progressView.progress = CGFloat(progress)
                if progress == 1.0 {
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+0.3, execute: {
                        self.progressView.progress = 0.0
                        self.progressView.isHidden = true
                    })
                }
            }
        }
        
        DispatchQueue.global(qos: .userInteractive).async {
            self.currentImageRequestID = PHImageManager.default().requestImage(for: asset,
                                                                               targetSize: targetSize,
                                                                               contentMode: .aspectFill,
                                                                               options: requestOptions) { (image, info) in
                if image != nil {
                    DispatchQueue.main.async {
                        self.setupFirstLoadingImageAttrabute(image: image!)
                    }
                }
                self.isOnDownloadingImage = false
            }
        }
    }
}

extension SMPhotoPickerLibraryView {
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == self.scrollView {
            self.squareMask.isHidden = false
            
            //print("Off Set:", scrollView.contentOffset)
        }
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        if scrollView == self.scrollView{
            self.squareMask.isHidden = true
            self.scaleRect = CGRect(origin: scrollView.contentOffset, size: scrollView.frame.size)
        }
    }
    
    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        
        if scrollView == self.scrollView{
            self.squareMask.isHidden = true
            self.scaleRect = CGRect(origin: scrollView.contentOffset, size: scrollView.frame.size)
        }
        
    }
    
    public func scrollViewDidZoom(_ scrollView: UIScrollView) {
        if scrollView == self.scrollView {
            self.squareMask.isHidden = false
        }
    }
    
    public func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        
        if scrollView == self.scrollView{
            //print(scale)
            self.scale = scale
            self.squareMask.isHidden = true
            self.scaleRect = CGRect(origin: scrollView.contentOffset, size: scrollView.frame.size)
        }
    }
    
    public func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
}
