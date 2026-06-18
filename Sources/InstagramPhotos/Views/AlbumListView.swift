import CoreGraphics
import SwiftUI

struct AlbumListView: View {
    let albums: [InstagramPhotosAlbum]
    let selectedAlbumID: String?
    let localization: any InstagramPhotosLocalizationProviding
    let imageLoader: ImageLoadingClient
    let libraryClient: any PhotosLibraryClientProtocol
    let configuration: InstagramPhotosPickerConfiguration
    let onSelect: (InstagramPhotosAlbum) -> Void

    var body: some View {
        Group {
            if albums.isEmpty {
                emptyState
            } else {
                albumList
            }
        }
        .background(PickerDesign.chromeBackground)
        .navigationTitle(localization.albumNavigationTitle())
        .navigationBarTitleDisplayMode(.large)
        .toolbarBackground(.visible, for: .navigationBar)
    }

    private var albumList: some View {
        List {
            ForEach(albums) { album in
                AlbumListRowButton(
                    album: album,
                    isSelected: album.id == selectedAlbumID,
                    localization: localization,
                    configuration: configuration,
                    libraryClient: libraryClient,
                    imageLoader: imageLoader,
                    onSelect: onSelect
                )
            }
        }
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)
    }

    @ViewBuilder
    private var emptyState: some View {
        if #available(iOS 17.0, *) {
            ContentUnavailableView {
                Label {
                    Text(localization.albumEmptyTitle())
                } icon: {
                    Image(systemName: "photo.on.rectangle.angled")
                }
            } description: {
                Text(localization.albumEmptyMessage())
            }
        } else {
            VStack(spacing: 12) {
                Image(systemName: "photo.on.rectangle.angled")
                    .font(.system(size: 44, weight: .light))
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(.secondary)
                    .accessibilityHidden(true)

                Text(localization.albumEmptyTitle())
                    .font(.title3.weight(.semibold))

                Text(localization.albumEmptyMessage())
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }

}

private struct AlbumListRowButton: View {
    let album: InstagramPhotosAlbum
    let isSelected: Bool
    let localization: any InstagramPhotosLocalizationProviding
    let configuration: InstagramPhotosPickerConfiguration
    let libraryClient: any PhotosLibraryClientProtocol
    let imageLoader: ImageLoadingClient
    let onSelect: (InstagramPhotosAlbum) -> Void

    var body: some View {
        Button {
            onSelect(album)
        } label: {
            AlbumListRow(
                album: album,
                isSelected: isSelected,
                localization: localization,
                configuration: configuration,
                libraryClient: libraryClient,
                imageLoader: imageLoader
            )
        }
        .buttonStyle(.plain)
        .listRowInsets(PickerDesign.albumListRowInsets)
        .accessibilityLabel("\(album.name), \(localization.albumPhotoCountText(album.assetCount))")
        .accessibilityAddTraits(isSelected ? .isSelected : AccessibilityTraits())
    }
}

private struct AlbumListRow: View {
    let album: InstagramPhotosAlbum
    let isSelected: Bool
    let localization: any InstagramPhotosLocalizationProviding
    let configuration: InstagramPhotosPickerConfiguration
    let libraryClient: any PhotosLibraryClientProtocol
    let imageLoader: ImageLoadingClient

    var body: some View {
        HStack(spacing: PickerDesign.albumListRowSpacing) {
            AlbumThumbnailView(
                album: album,
                configuration: configuration,
                libraryClient: libraryClient,
                imageLoader: imageLoader
            )
            .frame(
                width: PickerDesign.albumThumbnailSize,
                height: PickerDesign.albumThumbnailSize
            )
            .clipShape(
                RoundedRectangle(
                    cornerRadius: PickerDesign.albumThumbnailCornerRadius,
                    style: .continuous
                )
            )

            VStack(alignment: .leading, spacing: 2) {
                Text(album.name)
                    .font(.body)
                    .foregroundStyle(.primary)
                    .lineLimit(1)

                Text(localization.albumPhotoCountText(album.assetCount))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .monospacedDigit()
            }

            Spacer(minLength: 0)

            if isSelected {
                Image(systemName: "checkmark")
                    .font(.body.weight(.semibold))
                    .foregroundStyle(Color.accentColor)
                    .accessibilityHidden(true)
            }
        }
        .frame(minHeight: PickerDesign.albumListRowMinHeight)
        .contentShape(Rectangle())
    }
}

private struct AlbumThumbnailView: View {
    let album: InstagramPhotosAlbum
    let configuration: InstagramPhotosPickerConfiguration
    let libraryClient: any PhotosLibraryClientProtocol
    let imageLoader: ImageLoadingClient

    @State private var thumbnail: CGImage?

    var body: some View {
        ZStack {
            PickerDesign.placeholderFill

            if let thumbnail {
                Image(decorative: thumbnail, scale: 1, orientation: .up)
                    .resizable()
                    .scaledToFill()
            } else {
                Image(systemName: "photo")
                    .font(.title3.weight(.light))
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(.tertiary)
                    .accessibilityHidden(true)
            }
        }
        .task(id: album.id) {
            let assets = await libraryClient.fetchAssets(
                in: album.id,
                allowedMediaTypes: configuration.allowedMediaTypes
            )
            guard let first = assets.first else {
                thumbnail = nil
                return
            }

            let thumbnailSize = CGSize(
                width: PickerDesign.albumThumbnailSize * 2,
                height: PickerDesign.albumThumbnailSize * 2
            )
            if let result = try? await imageLoader.loadThumbnail(for: first, targetSize: thumbnailSize) {
                thumbnail = result.cgImage
            }
        }
    }
}

#if DEBUG
#Preview("Album List") {
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

#Preview("Empty") {
    NavigationStack {
        AlbumListView(
            albums: [],
            selectedAlbumID: nil,
            localization: InstagramPhotosPreviewData.configuration.localizationProvider,
            imageLoader: ImageLoadingClient.preview,
            libraryClient: PreviewPhotosLibraryClient(),
            configuration: InstagramPhotosPreviewData.configuration,
            onSelect: { _ in }
        )
    }
}
#endif