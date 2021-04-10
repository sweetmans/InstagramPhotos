//
//  AlbumModel.swift
//  SMInstagramPhotosPicker
//
//  Created by MacBook Pro on 2017/4/19.
//  Copyright © 2017年 Sweetman, Inc. All rights reserved.
//

import Foundation
import UIKit
import Photos


public class AlbumModel {
    
    let name:String
    let count:Int
    let collection:PHAssetCollection
    let assets: PHFetchResult<PHAsset>
    
    init(name:String, count:Int, collection:PHAssetCollection, assets: PHFetchResult<PHAsset>) {
        self.name = name
        self.count = count
        self.collection = collection
        self.assets = assets
    }
    
    
    static func listAlbums() -> [AlbumModel] {
        
        var album:[AlbumModel] = [AlbumModel]()
        
        let options = PHFetchOptions()
        let systemAlbums = PHAssetCollection.fetchAssetCollections(with: PHAssetCollectionType.smartAlbum, subtype: PHAssetCollectionSubtype.any, options: options)
        
        systemAlbums.enumerateObjects({ (object: AnyObject!, count: Int, stop: UnsafeMutablePointer) in
            if object is PHAssetCollection {
                let obj:PHAssetCollection = object as! PHAssetCollection
                
                let fetchOptions = PHFetchOptions()
                fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
                fetchOptions.predicate = NSPredicate(format: "mediaType = %d", PHAssetMediaType.image.rawValue)
                let assets = PHAsset.fetchAssets(in: obj, options: fetchOptions)
                
                if assets.count > 0 {
                    let newAlbum = AlbumModel(name: obj.localizedTitle!, count: assets.count, collection:obj, assets: assets)
                    album.append(newAlbum)
                }
            }
        })
        
        let userAlbums = PHAssetCollection.fetchAssetCollections(with: PHAssetCollectionType.album, subtype: PHAssetCollectionSubtype.any, options: options)
        
        userAlbums.enumerateObjects({ (object: AnyObject!, count: Int, stop: UnsafeMutablePointer) in
            if object is PHAssetCollection {
                let obj:PHAssetCollection = object as! PHAssetCollection
                
                let fetchOptions = PHFetchOptions()
                fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
                fetchOptions.predicate = NSPredicate(format: "mediaType = %d", PHAssetMediaType.image.rawValue)
                
                let assets = PHAsset.fetchAssets(in: obj, options: fetchOptions)
                if assets.count > 0 {
                    let newAlbum = AlbumModel(name: obj.localizedTitle!, count: assets.count, collection: obj, assets: assets)
                    album.append(newAlbum)
                }
            }
        })
        
        return album
        
    }
    
    func fetchFirstImage(returnImage: @escaping (UIImage) -> Void) {
        DispatchQueue.global(qos: .default).async(execute: {
            let op = PHFetchOptions()
            op.fetchLimit = 1
            op.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
            let assets = PHAsset.fetchAssets(in: self.collection, options: op)
            
            let rop = PHImageRequestOptions()
            rop.isNetworkAccessAllowed = true
            
            if assets.firstObject != nil {
                let ts = CGSize(width: assets.firstObject!.pixelWidth, height: assets.firstObject!.pixelHeight)
                PHImageManager.default().requestImage(for: assets.firstObject!, targetSize: ts, contentMode: .aspectFill, options: rop, resultHandler: { (image, info) in
                    if image != nil {
                        DispatchQueue.main.async {
                            returnImage(image!)
                        }
                        
                    }
                })
            }
        })
    }
    
}








