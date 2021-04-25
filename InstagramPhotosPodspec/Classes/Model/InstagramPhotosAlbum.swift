//
//  Copyright © 2021年 Sweetman, Inc. All rights reserved.
//

import Photos

public struct InstagramPhotosAlbum {
    let name: String
    let count: Int
    let collection: PHAssetCollection
    let assets: PHFetchResult<PHAsset>
}
