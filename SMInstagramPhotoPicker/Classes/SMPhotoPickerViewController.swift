//
//  SMPhotoPickerViewController.swift
//  SMInstagramPhotosPicker
//
//  Created by MacBook Pro on 2017/4/18.
//  Copyright © 2017年 Sweetman, Inc. All rights reserved.
//

import UIKit
import Photos

public protocol SMPhotoPickerViewControllerDelegate {
    func didFinishPickingPhoto(image: UIImage, meteData: [String: Any])
    func didCancelPickingPhoto()
}

public class SMPhotoPickerViewController: UIViewController, SMPhotoPickerAlbumViewDelegate {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var arrowImageView: UIImageView!
    @IBOutlet weak var selectAlbumButton: UIButton!
    @IBOutlet weak var bottomToolsView: UIView!
    
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    
    let albumView = SMPhotoPickerAlbumView.instance()
    let library: SMPhotoPickerLibraryView = SMPhotoPickerLibraryView.instance()
    
    var delegate: SMPhotoPickerViewControllerDelegate? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        albumView.delegate = self
        
        library.frame = CGRect(origin: CGPoint.zero, size: scrollView.frame.size)
        library.collectionView.reloadData()
        scrollView.addSubview(library)
        
        let title = "All Photos"
        selectAlbumButton.setTitle(title, for: .normal)
        let si = selectAlbumButton.titleLabel?.intrinsicContentSize
        selectAlbumButton.updateConstraint(attribute: .width, value: (si?.width)!)
        
        
        let down = #imageLiteral(resourceName: "arrowDown").withRenderingMode(.alwaysTemplate)
        
        arrowImageView.image = down
        albumView.frame = CGRect(x: 0, y: view.frame.height, width: view.frame.width, height: view.frame.height - 44.0)
        print(albumView.frame)
        view.addSubview(self.albumView)
    }
    
    @IBAction func showAlbums(_ sender: UIButton) {
        
        // handle show album list
        if !selectAlbumButton.isSelected {
            selectAlbumButton.isSelected = true
            
            print(self.bottomToolsView.frame)
            
            UIView.animate(withDuration: 0.3, animations: {
                var rect = self.bottomToolsView.frame
                rect.origin.y = self.view.frame.height
                self.bottomToolsView.frame = rect
            })
            
            UIView.animate(withDuration: 1, delay: 0.3, usingSpringWithDamping: 12, initialSpringVelocity: 12, options: .layoutSubviews, animations: {
                self.albumView.frame = CGRect(x: 0, y: 44, width: self.view.frame.width, height: self.view.frame.height - 44.0)
                self.arrowImageView.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi))
                
                self.cancelButton.isHidden = true
                self.nextButton.isHidden = true
            }) { (isComplete) in
                
                
            }
        }else {
            // handle hidn album list.
            UIView.animate(withDuration: 0.3, animations: {
                self.albumView.frame = CGRect(x: 0, y: self.view.frame.height, width: self.view.frame.width, height: self.view.frame.height - 44.0)
                self.arrowImageView.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi * 2))
                self.cancelButton.isHidden = false
                self.nextButton.isHidden = false
            })
            
            selectAlbumButton.isSelected = false
            UIView.animate(withDuration: 1, delay: 0.3, usingSpringWithDamping: 12, initialSpringVelocity: 12, options: .layoutSubviews, animations: {
                
                var rect = self.bottomToolsView.frame
                rect.origin.y = self.view.frame.height - 44.0
                self.bottomToolsView.frame = rect
            }, completion: { (isComplete) in
                
            })
            
        }
    }
    
    @IBAction func next(_ sender: UIButton) {
        
        if library.isOnDownloadingImage {
            
            let alert = UIAlertController.init(title: "Photo is downloading", message: "Please wait.", preferredStyle: .alert)
            let cancel = UIAlertAction.init(title: "Got it.", style: .cancel, handler: { (action) in
                
            })
            alert.addAction(cancel)
            
            self.present(alert, animated: true, completion: nil)

        }else{
            
            let image = library.imageView.image!.crop(rect: library.scaleRect, scale: library.imageScale / library.scale)
            let ass = library.currentAsset!
            var mateData: [String: Any] = [String: Any]()
            mateData["mediaType"] = ass.mediaType
            mateData["mediaSubtypes"] = ass.mediaSubtypes
            mateData["size"] = CGSize(width: ass.pixelWidth, height: ass.pixelHeight)
            mateData["creationTimestamp"] = Int((ass.creationDate?.timeIntervalSince1970)!)
            mateData["location"] = ass.location
            mateData["sourceType"] = ass.sourceType
            
            self.delegate?.didFinishPickingPhoto(image: image, meteData: mateData)
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func cancel(_ sender: UIButton) {
        delegate?.didCancelPickingPhoto()
        dismiss(animated: true, completion: nil)
    }
    
    override public func loadView() {
        
        if let view = UINib(nibName: "SMPhotoPickerViewController", bundle: Bundle(for: self.classForCoder)).instantiate(withOwner: self, options: nil).first as? UIView {
            view.frame = UIScreen.main.bounds
            self.view = view
            print("SMPhotoPickerViewController", self.view.frame)
        }
    }
    
    override public var prefersStatusBarHidden : Bool {
        
        return true
    }
    
    func didSeletctAlbum(album: AlbumModel) {
        
        selectAlbumButton.setTitle(album.name, for: .normal)
        let si = selectAlbumButton.titleLabel?.intrinsicContentSize
        selectAlbumButton.updateConstraint(attribute: .width, value: (si?.width)!)
        
        library.images = album.assets
        library.collectionView.reloadData()
        library.collectionView.selectItem(at: IndexPath.init(row: 0, section: 0), animated: false, scrollPosition: .bottom)
        album.fetchFirstImage { (image) in
            self.library.setupFirstLoadingImageAttrabute(image: image)

        }
        
        // handle hidn album list.
        UIView.animate(withDuration: 0.3, animations: {
            self.albumView.frame = CGRect(x: 0, y: self.view.frame.height, width: self.view.frame.width, height: self.view.frame.height - 44.0)
            self.arrowImageView.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi * 2))
            self.cancelButton.isHidden = false
            self.nextButton.isHidden = false
        })
        
        selectAlbumButton.isSelected = false
        UIView.animate(withDuration: 1, delay: 0.3, usingSpringWithDamping: 12, initialSpringVelocity: 12, options: .layoutSubviews, animations: {
            
            var rect = self.bottomToolsView.frame
            rect.origin.y = self.view.frame.height - 44.0
            self.bottomToolsView.frame = rect
        }, completion: { (isComplete) in
            
        })
        
    }
    
}










