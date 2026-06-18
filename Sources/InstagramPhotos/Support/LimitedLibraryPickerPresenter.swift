#if canImport(UIKit)
import Photos
import PhotosUI
import UIKit

/// Presents the system limited photo library picker so users can add or remove authorized photos.
@MainActor
enum LimitedLibraryPickerPresenter {
    static func present(onCompletion: (@MainActor () -> Void)? = nil) {
        guard let controller = topViewController() else { return }

        if #available(iOS 15, *) {
            PHPhotoLibrary.shared().presentLimitedLibraryPicker(from: controller) { _ in
                Task { @MainActor in
                    onCompletion?()
                }
            }
        } else {
            PHPhotoLibrary.shared().presentLimitedLibraryPicker(from: controller)
            onCompletion?()
        }
    }

    private static func topViewController() -> UIViewController? {
        let scenes = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .filter { $0.activationState == .foregroundActive || $0.activationState == .foregroundInactive }

        guard let window = scenes
            .flatMap(\.windows)
            .first(where: \.isKeyWindow),
            var controller = window.rootViewController
        else {
            return nil
        }

        while let presented = controller.presentedViewController {
            controller = presented
        }

        return controller
    }
}
#endif