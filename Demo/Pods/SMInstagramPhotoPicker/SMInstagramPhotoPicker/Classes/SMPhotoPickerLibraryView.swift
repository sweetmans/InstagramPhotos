//
//  SMPhotoPickerLibraryView.swift
//  SMInstagramPhotosPicker
//
//  Created by MacBook Pro on 2017/4/18.
//  Copyright © 2017年 Sweetman, Inc. All rights reserved.
//

import UIKit
import Photos

class SMPhotoPickerLibraryView: UIView, UICollectionViewDelegate, UICollectionViewDataSource, UIScrollViewDelegate {
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    var imageView: UIImageView = {
        let i = UIImageView()
        i.contentMode = .scaleAspectFill
        i.clipsToBounds = true
        return i
    }()
    
    @IBOutlet weak var squareMask: UIImageView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var progressView: SMProgressView!
    
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
    
    static func instance() -> SMPhotoPickerLibraryView {
        
        let view = UINib(nibName: "SMPhotoPickerLibraryView", bundle: Bundle(for: self.classForCoder())).instantiate(withOwner: self, options: nil)[0] as! SMPhotoPickerLibraryView
        
        view.initialize()
        //print("Library Width", view.frame)
        return view
    }
    
    func initialize() {
        
        if images != nil {
            
            return
        }
        
        scrollView.addSubview(imageView)
        imageView.frame = scrollView.frame
        
        collectionView.register(UINib(nibName: "SMPhotoPickerImageCell", bundle: Bundle(for: self.classForCoder)), forCellWithReuseIdentifier: "SMPhotoPickerImageCell")
        
        let allAlbums = AlbumModel.listAlbums()
        let allPhotosAlbum = allAlbums.first!
        images = allPhotosAlbum.assets
        
        currentAsset = allPhotosAlbum.assets.firstObject
        
        allPhotosAlbum.fetchFirstImage { (image) in
            
            self.setupFirstLoadingImageAttrabute(image: image)
            self.isOnDownloadingImage = false
            //print(self.scrollView.zoomScale)
        }
        
        collectionView.selectItem(at: IndexPath.init(row: 0, section: 0), animated: false, scrollPosition: .bottom)
        
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
        var s = CGSize(width: 0, height: 0)
        if original.width > original.height {
            let scale = original.height / target.height
            let w = original.width / scale
            self.imageScale = scale
            s = CGSize(width: w, height: target.height)
        }else{
            let scale = original.width / target.width
            let w = original.height / scale
            self.imageScale = scale
            s = CGSize(width: target.width, height: w)
        }
        
        return s
    }
 
}















