import Foundation

/// Localization provider for picker strings.
public protocol InstagramPhotosLocalizationProviding: Sendable {
    func pickerNavigationTitle() -> String
    func pickerNavigationCancelButtonText() -> String
    func pickerNavigationNextButtonText() -> String
    func pickerSingleSelectionModeText() -> String
    func pickerMultipleSelectionModeText() -> String
    func pickerDefaultAlbumName() -> String
    func pickerAddingImageAccessButtonText() -> String
    func albumNavigationTitle() -> String
    func albumNavigationCancelButtonText() -> String
    func albumPhotoCountText(_ count: Int) -> String
    func albumEmptyTitle() -> String
    func albumEmptyMessage() -> String
    func photosLimitedAccessTitle() -> String
    func photosLimitedAccessModeText() -> String

    func permissionDeniedTitle() -> String
    func permissionDeniedMessage() -> String
    func permissionRestrictedTitle() -> String
    func permissionRestrictedMessage() -> String
    func permissionRequestAccessButtonText() -> String
    func permissionOpenSettingsButtonText() -> String
    func iCloudDownloadingText() -> String
    func selectionLimitReachedText() -> String
    func pickerShowPreviewButtonText() -> String
    func pickerCollapseHeaderAccessibilityLabel() -> String
    func pickerCollapseHeaderAccessibilityHint(isCollapsed: Bool) -> String
}

public extension InstagramPhotosLocalizationProviding {
    func pickerNavigationCancelButtonText() -> String { "Cancel" }
    func permissionDeniedTitle() -> String { "Photos Access Needed" }
    func permissionDeniedMessage() -> String {
        "Allow access to your photo library in Settings to pick photos."
    }
    func permissionRestrictedTitle() -> String { "Photos Access Restricted" }
    func permissionRestrictedMessage() -> String {
        "Photo library access is restricted on this device."
    }
    func permissionRequestAccessButtonText() -> String { "Allow Access" }
    func permissionNotDeterminedMessage() -> String {
        "Allow access to your photo library to pick photos."
    }
    func permissionOpenSettingsButtonText() -> String { "Open Settings" }
    func iCloudDownloadingText() -> String { "Downloading from iCloud…" }
    func selectionLimitReachedText() -> String { "Selection limit reached" }
    func pickerSingleSelectionModeText() -> String { "Single" }
    func pickerMultipleSelectionModeText() -> String { "Multiple" }
    func photosLimitedAccessTitle() -> String { "Limited Access" }

    func pickerShowPreviewButtonText() -> String { "Show Preview" }
    func pickerCollapseHeaderAccessibilityLabel() -> String { "Photo preview handle" }
    func pickerCollapseHeaderAccessibilityHint(isCollapsed: Bool) -> String {
        isCollapsed ? "Swipe down to show photo preview" : "Swipe up to show more photos"
    }

    func albumPhotoCountText(_ count: Int) -> String {
        count == 1 ? "1 Photo" : "\(count) Photos"
    }

    func albumEmptyTitle() -> String { "No Albums" }
    func albumEmptyMessage() -> String {
        "No photo albums are available with the current media filters."
    }
}

public struct InstagramPhotosEnglishLocalizationProvider: InstagramPhotosLocalizationProviding {
    public init() {}

    public func pickerNavigationTitle() -> String { "Photos" }
    public func pickerNavigationCancelButtonText() -> String { "Cancel" }
    public func pickerNavigationNextButtonText() -> String { "Add" }
    public func pickerSingleSelectionModeText() -> String { "Single" }
    public func pickerMultipleSelectionModeText() -> String { "Multiple" }
    public func pickerDefaultAlbumName() -> String { "Recents" }
    public func pickerAddingImageAccessButtonText() -> String { "Add more photos" }
    public func albumNavigationTitle() -> String { "Albums" }
    public func albumNavigationCancelButtonText() -> String { "Cancel" }
    public func albumPhotoCountText(_ count: Int) -> String {
        count == 1 ? "1 Photo" : "\(count) Photos"
    }
    public func albumEmptyTitle() -> String { "No Albums" }
    public func albumEmptyMessage() -> String {
        "No photo albums are available with the current media filters."
    }
    public func photosLimitedAccessTitle() -> String { "Limited Access" }
    public func photosLimitedAccessModeText() -> String {
        "You've granted access to only a subset of your photo library. Choose additional photos and albums that can be used in this app."
    }

    public func pickerShowPreviewButtonText() -> String { "Show Preview" }
    public func pickerCollapseHeaderAccessibilityLabel() -> String { "Photo preview handle" }
    public func pickerCollapseHeaderAccessibilityHint(isCollapsed: Bool) -> String {
        isCollapsed ? "Swipe down to show photo preview" : "Swipe up to show more photos"
    }
}

public struct InstagramPhotosChineseLocalizationProvider: InstagramPhotosLocalizationProviding {
    public init() {}

    public func pickerNavigationTitle() -> String { "照片" }
    public func pickerNavigationCancelButtonText() -> String { "取消" }
    public func pickerNavigationNextButtonText() -> String { "添加" }
    public func pickerSingleSelectionModeText() -> String { "单选" }
    public func pickerMultipleSelectionModeText() -> String { "多选" }
    public func pickerDefaultAlbumName() -> String { "最近项目" }
    public func pickerAddingImageAccessButtonText() -> String { "添加更多照片" }
    public func albumNavigationTitle() -> String { "相册" }
    public func albumNavigationCancelButtonText() -> String { "取消" }
    public func albumPhotoCountText(_ count: Int) -> String {
        count == 1 ? "1 张照片" : "\(count) 张照片"
    }
    public func albumEmptyTitle() -> String { "没有相册" }
    public func albumEmptyMessage() -> String {
        "当前媒体筛选条件下没有可用的相册。"
    }
    public func photosLimitedAccessTitle() -> String { "有限访问" }
    public func photosLimitedAccessModeText() -> String {
        "你仅授权了部分照片库访问权限。可选择更多照片和相册供此 App 使用。"
    }
    public func permissionRequestAccessButtonText() -> String { "允许访问" }
    public func pickerShowPreviewButtonText() -> String { "显示预览" }
    public func pickerCollapseHeaderAccessibilityLabel() -> String { "照片预览拖动手柄" }
    public func pickerCollapseHeaderAccessibilityHint(isCollapsed: Bool) -> String {
        isCollapsed ? "向下拖动手柄以显示照片预览" : "向上拖动手柄以显示更多照片"
    }
}

// MARK: - Legacy compatibility

@available(*, deprecated, renamed: "InstagramPhotosLocalizationProviding")
public typealias InstagramPhotosLocalizationsProviding = InstagramPhotosLocalizationProviding

public extension InstagramPhotosLocalizationProviding {
    @available(*, deprecated, renamed: "pickerNavigationTitle")
    func pinkingControllerNavigationTitle() -> String { pickerNavigationTitle() }

    @available(*, deprecated, renamed: "pickerNavigationNextButtonText")
    func pinkingControllerNavigationNextButtonText() -> String { pickerNavigationNextButtonText() }

    @available(*, deprecated, renamed: "pickerDefaultAlbumName")
    func pinkingControllerDefaultAlbumName() -> String { pickerDefaultAlbumName() }

    @available(*, deprecated, renamed: "pickerAddingImageAccessButtonText")
    func pinkingControllerAddingImageAccessButtonText() -> String { pickerAddingImageAccessButtonText() }

    @available(*, deprecated, renamed: "albumNavigationTitle")
    func albumControllerNavigationTitle() -> String { albumNavigationTitle() }

    @available(*, deprecated, renamed: "albumNavigationCancelButtonText")
    func albumControllerNavigationCancelButtonText() -> String { albumNavigationCancelButtonText() }
}