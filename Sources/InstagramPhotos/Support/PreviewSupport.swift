#if DEBUG
import CoreGraphics
import Photos
import SwiftUI

enum InstagramPhotosPreviewData {
    static let configuration = InstagramPhotosPickerConfiguration(
        selectionLimit: 10,
        allowsMultipleSelection: true,
        showsSelectionModeToggle: true,
        iCloudNetworkAccessAllowed: true
    )

    static let assets: [InstagramPhotosAsset] = (0..<16).map { index in
        InstagramPhotosAsset(
            id: "preview-asset-\(index)",
            mediaType: .image,
            pixelWidth: 1200,
            pixelHeight: 1200,
            creationDate: Date().addingTimeInterval(TimeInterval(-index * 3600)),
            isLocallyAvailable: index % 4 != 0
        )
    }

    static let albums: [InstagramPhotosAlbum] = [
        InstagramPhotosAlbum(id: "preview-album-recents", name: "Recents", assetCount: 128),
        InstagramPhotosAlbum(id: "preview-album-favorites", name: "Favorites", assetCount: 24),
        InstagramPhotosAlbum(id: "preview-album-screenshots", name: "Screenshots", assetCount: 56),
    ]

    static var selectedAlbum: InstagramPhotosAlbum { albums[0] }

    @MainActor
    static func makeSelection(selectedCount: Int = 2) -> InstagramPhotosSelection {
        let selection = InstagramPhotosSelection(configuration: configuration)
        for asset in assets.prefix(selectedCount) {
            selection.toggle(asset)
        }
        return selection
    }

    static func placeholderCGImage(seed: Int, size: Int = 400) -> CGImage? {
        let width = size
        let height = size
        guard let context = CGContext(
            data: nil,
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: 0,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        ) else {
            return nil
        }

        let hue = CGFloat(UInt(bitPattern: seed) % 255) / 255.0
        let red = min(max(0.15 + hue * 0.5, 0), 1)
        let green = CGFloat(0.35)
        let blue = CGFloat(0.75)
        context.setFillColor(red: red, green: green, blue: blue, alpha: 1)
        context.fill(CGRect(x: 0, y: 0, width: width, height: height))

        context.setStrokeColor(gray: 1, alpha: 0.35)
        context.setLineWidth(4)
        context.stroke(CGRect(x: 8, y: 8, width: width - 16, height: height - 16))

        return context.makeImage()
    }
}

struct PickerPreviewState {
    var authorizationStatus: InstagramPhotosAuthorizationStatus
    var albums: [InstagramPhotosAlbum]
    var assets: [InstagramPhotosAsset]
    var selectedAlbum: InstagramPhotosAlbum?

    static let authorized = PickerPreviewState(
        authorizationStatus: .authorized,
        albums: InstagramPhotosPreviewData.albums,
        assets: InstagramPhotosPreviewData.assets,
        selectedAlbum: InstagramPhotosPreviewData.selectedAlbum
    )

    static let limited = PickerPreviewState(
        authorizationStatus: .limited,
        albums: InstagramPhotosPreviewData.albums,
        assets: InstagramPhotosPreviewData.assets,
        selectedAlbum: InstagramPhotosPreviewData.selectedAlbum
    )

    static let denied = PickerPreviewState(
        authorizationStatus: .denied,
        albums: [],
        assets: [],
        selectedAlbum: nil
    )

    static let notDetermined = PickerPreviewState(
        authorizationStatus: .notDetermined,
        albums: [],
        assets: [],
        selectedAlbum: nil
    )
}

struct PreviewPhotosLibraryClient: PhotosLibraryClientProtocol {
    func fetchAlbums(allowedMediaTypes: Set<PHAssetMediaType>) async -> [InstagramPhotosAlbum] {
        InstagramPhotosPreviewData.albums
    }

    func fetchAssets(
        in albumID: String,
        allowedMediaTypes: Set<PHAssetMediaType>
    ) async -> [InstagramPhotosAsset] {
        InstagramPhotosPreviewData.assets
    }

    func fetchAsset(localIdentifier: String) async -> InstagramPhotosAsset? {
        InstagramPhotosPreviewData.assets.first { $0.id == localIdentifier }
    }
}

@MainActor
enum InstagramPhotosPreviewHostFactory {
    static func photoGrid(selection: InstagramPhotosSelection) -> some View {
        PhotoGridView(
            assets: InstagramPhotosPreviewData.assets,
            cellSide: 120,
            configuration: InstagramPhotosPreviewData.configuration,
            selection: selection,
            imageLoader: ImageLoadingClient.preview,
            onAssetFocused: { _ in }
        )
    }

    static func albumList() -> some View {
        NavigationStack {
            AlbumListView(
                albums: InstagramPhotosPreviewData.albums,
                selectedAlbumID: InstagramPhotosPreviewData.selectedAlbum.id,
                localization: InstagramPhotosPreviewData.configuration.localizationProvider,
                imageLoader: ImageLoadingClient.preview,
                libraryClient: PreviewPhotosLibraryClient(),
                configuration: InstagramPhotosPreviewData.configuration,
                onSelect: { _ in }
            )
        }
    }

    static func photoPreview(asset: InstagramPhotosAsset? = InstagramPhotosPreviewData.assets.first) -> some View {
        PhotoPreviewView(
            asset: asset,
            configuration: InstagramPhotosPreviewData.configuration,
            imageLoader: ImageLoadingClient.preview,
            onPreviewCropChanged: { _ in }
        )
    }

    static func pickerRoot(state: PickerPreviewState) -> some View {
        PickerRootView(previewState: state)
    }

    static func limitedAccessBanner(
        isExpanded: Bool = false,
        headerCollapseProgress: CGFloat = 0
    ) -> some View {
        LimitedAccessBannerView(
            title: InstagramPhotosPreviewData.configuration.localizationProvider.photosLimitedAccessTitle(),
            description: InstagramPhotosPreviewData.configuration.localizationProvider.photosLimitedAccessModeText(),
            actionTitle: InstagramPhotosPreviewData.configuration.localizationProvider.pickerAddingImageAccessButtonText(),
            isExpanded: isExpanded,
            headerCollapseProgress: headerCollapseProgress,
            onToggle: {},
            onManageAccess: {}
        )
    }
}
#endif