//
//  Copyright © 2021年 Sweetman, Inc. All rights reserved.
//

import Foundation
import Photos
import UIKit

public typealias InstagramImageFetchAssetImageResult = Result<UIImage, InstagramImageFetchAssetImageError>

public enum InstagramImageFetchAssetImageError: Error {
    case emptyAsset
    case requestImageFailure
}

public enum InstagramImageFetchAssetTargetSize {
    case original
    case thumbnail
    case appleDevice
}

protocol InstagramImageFetchAssetTargetSizeProviding {
    func tagetImageSizeFrom(asset: PHAsset, size: InstagramImageFetchAssetTargetSize) -> CGSize
}

struct InstagramImageFetchAssetTargetSizeProvider: InstagramImageFetchAssetTargetSizeProviding {
    func tagetImageSizeFrom(asset: PHAsset, size: InstagramImageFetchAssetTargetSize) -> CGSize {
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

public protocol InstagramImageAlbumsProviding {
    func listAllAlbums() -> [InstagramImageAlbum]
    func fetchAssetImage(asset: PHAsset, size: InstagramImageFetchAssetTargetSize, completion: @escaping (InstagramImageFetchAssetImageResult) -> Void)
    func fetchAlbumFirstAsset(collection: PHAssetCollection) -> PHAsset?
}

public struct InstagramImageAlbumsProvider: InstagramImageAlbumsProviding {
    private let targetSizeProvider: InstagramImageFetchAssetTargetSizeProviding = InstagramImageFetchAssetTargetSizeProvider()
    
    public init() {}
    
    public func listAllAlbums() -> [InstagramImageAlbum] {
        var albums:[InstagramImageAlbum] = [InstagramImageAlbum]()
        for type in [PHAssetCollectionType.smartAlbum, PHAssetCollectionType.album] {
            let collections = PHAssetCollection.fetchAssetCollections(with: type, subtype: .any, options: nil)
            collections.enumerateObjects { collection, index, stop in
                let fetchOptions = PHFetchOptions()
                fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
                fetchOptions.predicate = NSPredicate(format: "mediaType = %d", PHAssetMediaType.image.rawValue)
                let assets = PHAsset.fetchAssets(in: collection, options: fetchOptions)
                if assets.count > 0,
                   let name = collection.localizedTitle {
                    let newAlbum = InstagramImageAlbum(name: name,
                                                       count: assets.count,
                                                       collection: collection,
                                                       assets: assets)
                    albums.append(newAlbum)
                }
            }
        }
        return albums
    }
    
    public func fetchAssetImage(asset: PHAsset, size: InstagramImageFetchAssetTargetSize = .original, completion: @escaping (InstagramImageFetchAssetImageResult) -> Void) {
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
