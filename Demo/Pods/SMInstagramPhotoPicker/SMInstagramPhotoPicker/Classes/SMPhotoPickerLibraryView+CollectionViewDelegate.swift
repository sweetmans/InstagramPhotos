//
//  SMPhotoPickerLibraryView+CollectionViewDelegate.swift
//  SMInstagramPhotosPicker
//
//  Created by MacBook Pro on 2017/4/18.
//  Copyright © 2017年 Sweetman, Inc. All rights reserved.
//

import Foundation
import UIKit
import Photos

extension SMPhotoPickerLibraryView {
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SMPhotoPickerImageCell", for: indexPath) as! SMPhotoPickerImageCell
        
        let asset = self.images[(indexPath as NSIndexPath).item]
        
        PHImageManager.default().requestImage(for: asset, targetSize: cellSize, contentMode: .aspectFill, options: nil) { (image, info) in
            cell.image = image
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return images == nil ? 0 : images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize {

        let width = (collectionView.frame.width - 3) / 4.00
        //print("Cell Width", width, collectionView.frame.width)
        return CGSize(width: width, height: width)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
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
        let op = PHImageRequestOptions()
        op.isNetworkAccessAllowed = true
        op.progressHandler = {(progress, err, pointer, info) in
            
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
            //print(progress)
        }
        
        self.currentImageRequestID = PHImageManager.default().requestImage(for: asset, targetSize: targetSize, contentMode: .aspectFill, options: op) { (image, info) in
            
            if let isInCloud = info?[PHImageResultIsInCloudKey] as? Bool {
                
                self.isOnDownloadingImage = isInCloud
            }
            
            if image != nil {
                //self.isOnDownloadingImage = false
                self.setupFirstLoadingImageAttrabute(image: image!)
            }
        }
        
    }
    
}













