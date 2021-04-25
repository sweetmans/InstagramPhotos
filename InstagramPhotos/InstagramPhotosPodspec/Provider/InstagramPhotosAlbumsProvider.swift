//
//  Copyright © 2021年 Sweetman, Inc. All rights reserved.
//

import Foundation
import Photos
import UIKit

public typealias InstagramPhotosFetchAssetImageResult = Result<UIImage, InstagramPhotosFetchAssetImageError>

public enum InstagramPhotosFetchAssetImageError: Error {
    case emptyAsset
    case requestImageFailure
}

public enum InstagramPhotosFetchAssetTargetSize {
    case original
    case thumbnail
    case appleDevice
}

protocol InstagramPhotosFetchAssetTargetSizeProviding {
    func tagetImageSizeFrom(asset: PHAsset, size: InstagramPhotosFetchAssetTargetSize) -> CGSize
}

struct InstagramPhotosFetchAssetTargetSizeProvider: InstagramPhotosFetchAssetTargetSizeProviding {
    func tagetImageSizeFrom(asset: PHAsset, size: InstagramPhotosFetchAssetTargetSize) -> CGSize {
        switch size {
        case .thumbnail:
            return CGSize(width: 300, height: 300)
        case .original:
            return CGSize(width: asset.pixelWidth, height: asset.pixelHeight)
        case .appleDevice:
            return CGSize(width: UIScreen.main.bounds.width * UIScreen.main.scale, height: UIScreen.main.bounds.width * UIScreen.main.scale)
        }
    }
}

public protocol InstagramPhotosAlbumsProviding {
    func listAllAlbums() -> [InstagramPhotosAlbum]
    func fetchAssetImage(asset: PHAsset, size: InstagramPhotosFetchAssetTargetSize, completion: @escaping (InstagramPhotosFetchAssetImageResult) -> Void)
    func fetchAlbumFirstAsset(collection: PHAssetCollection) -> PHAsset?
}

public struct InstagramPhotosAlbumsProvider: InstagramPhotosAlbumsProviding {
    private let targetSizeProvider: InstagramPhotosFetchAssetTargetSizeProviding = InstagramPhotosFetchAssetTargetSizeProvider()
    
    public init() {}
    
    public func listAllAlbums() -> [InstagramPhotosAlbum] {
        var albums:[InstagramPhotosAlbum] = [InstagramPhotosAlbum]()
        for type in [PHAssetCollectionType.smartAlbum, PHAssetCollectionType.album] {
            let collections = PHAssetCollection.fetchAssetCollections(with: type, subtype: .any, options: nil)
            collections.enumerateObjects { collection, index, stop in
                let fetchOptions = PHFetchOptions()
                fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
                fetchOptions.predicate = NSPredicate(format: "mediaType = %d", PHAssetMediaType.image.rawValue)
                let assets = PHAsset.fetchAssets(in: collection, options: fetchOptions)
                if assets.count > 0,
                   let name = collection.localizedTitle {
                    let newAlbum = InstagramPhotosAlbum(name: name,
                                                       count: assets.count,
                                                       collection: collection,
                                                       assets: assets)
                    albums.append(newAlbum)
                }
            }
        }
        return albums
    }
    
    public func fetchAssetImage(asset: PHAsset, size: InstagramPhotosFetchAssetTargetSize = .original, completion: @escaping (InstagramPhotosFetchAssetImageResult) -> Void) {
        DispatchQueue.global(qos: .userInteractive).async(execute: {
            let requestOptions = PHImageRequestOptions()
            requestOptions.isNetworkAccessAllowed = true
            let targetSize = targetSizeProvider.tagetImageSizeFrom(asset: asset, size: size)
            PHImageManager.default().requestImage(for: asset,
                                                  targetSize: targetSize,
                                                  contentMode: .aspectFill,
                                                  options: requestOptions,
                                                  resultHandler: { image, info in
                                                    guard let unwrapImage = image else { completion(.failure(.requestImageFailure))
                                                        return
                                                    }
                                                    DispatchQueue.main.async {
                                                        completion(.success(unwrapImage))
                                                    }
                                                  })
        })
    }
    
    public func fetchAlbumFirstAsset(collection: PHAssetCollection) -> PHAsset? {
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        fetchOptions.predicate = NSPredicate(format: "mediaType = %d", PHAssetMediaType.image.rawValue)
        let assets = PHAsset.fetchAssets(in: collection, options: fetchOptions)
        return assets.firstObject
    }
}
