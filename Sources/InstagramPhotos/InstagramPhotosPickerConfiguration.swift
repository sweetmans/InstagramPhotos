import CoreGraphics
import Photos

/// Configuration options for ``InstagramPhotosPicker``.
public struct InstagramPhotosPickerConfiguration: Sendable {
    /// Maximum number of assets that can be selected. `0` means no limit.
    public var selectionLimit: Int

    /// Media types shown in the picker. Defaults to images only.
    public var allowedMediaTypes: Set<PHAssetMediaType>

    /// Whether the user can select more than one asset.
    public var allowsMultipleSelection: Bool

    /// Shows a toolbar control for switching between single and multiple selection.
    public var showsSelectionModeToggle: Bool

    /// Target size for grid thumbnails.
    public var thumbnailSize: CGSize

    /// Album local identifier to open first. `nil` uses the first available album.
    public var preferredAlbumIdentifier: String?

    /// Whether PhotoKit may download iCloud-backed assets over the network.
    public var iCloudNetworkAccessAllowed: Bool

    /// Whether download progress UI is shown for iCloud assets.
    public var showsProgress: Bool

    /// Requests the system photo permission dialog automatically when the picker opens.
    /// When `false`, users tap Allow Access on the permission screen instead.
    /// Keep this `false` when the host app already requests photo access to avoid duplicate prompts.
    public var automaticallyRequestsPhotoAccess: Bool

    /// Localization strings provider.
    public var localizationProvider: any InstagramPhotosLocalizationProviding

    public init(
        selectionLimit: Int = 1,
        allowedMediaTypes: Set<PHAssetMediaType> = [.image],
        allowsMultipleSelection: Bool = false,
        showsSelectionModeToggle: Bool = true,
        thumbnailSize: CGSize = CGSize(width: 300, height: 300),
        preferredAlbumIdentifier: String? = nil,
        iCloudNetworkAccessAllowed: Bool = true,
        showsProgress: Bool = true,
        automaticallyRequestsPhotoAccess: Bool = false,
        localizationProvider: any InstagramPhotosLocalizationProviding = InstagramPhotosEnglishLocalizationProvider()
    ) {
        self.selectionLimit = selectionLimit
        self.allowedMediaTypes = allowedMediaTypes
        self.allowsMultipleSelection = allowsMultipleSelection
        self.showsSelectionModeToggle = showsSelectionModeToggle
        self.thumbnailSize = thumbnailSize
        self.preferredAlbumIdentifier = preferredAlbumIdentifier
        self.iCloudNetworkAccessAllowed = iCloudNetworkAccessAllowed
        self.showsProgress = showsProgress
        self.automaticallyRequestsPhotoAccess = automaticallyRequestsPhotoAccess
        self.localizationProvider = localizationProvider
    }

    /// Effective selection limit accounting for single-selection mode.
    public var effectiveSelectionLimit: Int {
        if allowsMultipleSelection {
            return selectionLimit == 0 ? .max : selectionLimit
        }
        return 1
    }

    /// Returns `true` when another asset may be added to the current selection.
    public func canSelectAdditional(count: Int) -> Bool {
        count < effectiveSelectionLimit
    }
}