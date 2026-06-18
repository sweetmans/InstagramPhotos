import Foundation
import Photos

/// Authorization status mirrored from PhotoKit for testability.
public enum InstagramPhotosAuthorizationStatus: Int, Equatable, Sendable {
    case notDetermined
    case restricted
    case denied
    case authorized
    case limited

    public var canBrowseLibrary: Bool {
        self == .authorized || self == .limited
    }
}

public protocol PhotosAuthorizationClientProtocol: Sendable {
    func currentStatus() -> InstagramPhotosAuthorizationStatus
    func requestAuthorization() async -> InstagramPhotosAuthorizationStatus
}

public struct PhotosAuthorizationClient: PhotosAuthorizationClientProtocol {
    public init() {}

    public func currentStatus() -> InstagramPhotosAuthorizationStatus {
        resolvedAuthorizationStatus()
    }

    public func requestAuthorization() async -> InstagramPhotosAuthorizationStatus {
        let existing = currentStatus()
        guard existing == .notDetermined else { return existing }

        return await withCheckedContinuation { continuation in
            PHPhotoLibrary.requestAuthorization(for: .readWrite) { status in
                continuation.resume(returning: map(status))
            }
        }
    }

    private func resolvedAuthorizationStatus() -> InstagramPhotosAuthorizationStatus {
        if #available(iOS 14, *) {
            let readWriteStatus = PHPhotoLibrary.authorizationStatus(for: .readWrite)
            if readWriteStatus != .notDetermined {
                return map(readWriteStatus)
            }
        }
        return map(PHPhotoLibrary.authorizationStatus())
    }

}

public extension InstagramPhotosAuthorizationStatus {
    /// Returns the current photo-library authorization status for the host app.
    static var current: InstagramPhotosAuthorizationStatus {
        PhotosAuthorizationClient().currentStatus()
    }
}

private extension PhotosAuthorizationClient {
    func map(_ status: PHAuthorizationStatus) -> InstagramPhotosAuthorizationStatus {
        switch status {
        case .notDetermined: return .notDetermined
        case .restricted: return .restricted
        case .denied: return .denied
        case .authorized: return .authorized
        case .limited: return .limited
        @unknown default: return .notDetermined
        }
    }
}