//
//  Copyright © 2021年 Sweetman, Inc. All rights reserved.
//

import Foundation
import Photos

public enum InstagramPhotosAuthorizationStatus: Int {
    case notDetermined
    case restricted
    case denied
    case authorized
    case limited
}


protocol InstagramPhotosAuthorizationProviding {
    func requestAuthorization(handler: @escaping (InstagramPhotosAuthorizationStatus) -> Void)
    func authorizationStatus() -> InstagramPhotosAuthorizationStatus
}

struct InstagramPhotosAuthorizationProvider: InstagramPhotosAuthorizationProviding {
    func authorizationStatus() -> InstagramPhotosAuthorizationStatus {
        if #available(iOS 14, *) {
            return covertPHAuthorizationStatusToInstagramPhotosAuthorizationStatus(from: PHPhotoLibrary.authorizationStatus(for: .readWrite))
        } else {
            return covertPHAuthorizationStatusToInstagramPhotosAuthorizationStatus(from: PHPhotoLibrary.authorizationStatus())
        }
    }
    
    func requestAuthorization(handler: @escaping (InstagramPhotosAuthorizationStatus) -> Void) {
        let completion = { status in
            handler(self.covertPHAuthorizationStatusToInstagramPhotosAuthorizationStatus(from: status))
        }
        if #available(iOS 14, *) {
            PHPhotoLibrary.requestAuthorization(for: .readWrite, handler: completion)
        } else {
            PHPhotoLibrary.requestAuthorization(completion)
        }
    }
    
    private func covertPHAuthorizationStatusToInstagramPhotosAuthorizationStatus(from: PHAuthorizationStatus) -> InstagramPhotosAuthorizationStatus {
        switch from {
        case .restricted:
            return .restricted
        case .denied:
            return .denied
        case .authorized:
            return .authorized
        case .limited:
            return .limited
        default:
            return .notDetermined
        }
    }
}
