import CoreGraphics
import SwiftUI

struct PhotoGridCell: View {
    let asset: InstagramPhotosAsset
    let cellSide: CGFloat
    let selectionIndex: Int?
    let showsSelectionOrder: Bool
    let imageLoader: ImageLoadingClient
    let onTap: () -> Void

    @Environment(\.displayScale) private var displayScale

    @State private var thumbnail: CGImage?
    @State private var isInCloud = false
    @State private var loadTask: Task<Void, Never>?
    @State private var loadedTargetSide: CGFloat = 0

    private var isSelected: Bool { selectionIndex != nil }

    private var targetSize: CGSize {
        CGSize(width: cellSide, height: cellSide)
    }

    var body: some View {
        ZStack {
            Group {
                if let thumbnail {
                    Image(decorative: thumbnail, scale: displayScale, orientation: .up)
                        .resizable()
                        .scaledToFill()
                } else {
                    PickerDesign.placeholderFill
                }
            }
            .frame(width: cellSide, height: cellSide)
            .clipped()

            if isSelected {
                Color.primary.opacity(0.15)
            }

            if isInCloud {
                Image(systemName: "icloud.and.arrow.down")
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(.primary)
                    .padding(5)
                    .background(.ultraThinMaterial, in: Circle())
                    .padding(PickerDesign.selectionBadgePadding)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
                    .accessibilityLabel("Stored in iCloud")
            }

            if isSelected {
                selectionBadge
                    .padding(PickerDesign.selectionBadgePadding)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
            }
        }
        .frame(width: cellSide, height: cellSide)
        .contentShape(Rectangle())
        .onTapGesture(perform: onTap)
        .onAppear {
            reloadThumbnailIfNeeded()
        }
        .onDisappear {
            loadTask?.cancel()
            loadTask = nil
        }
        .accessibilityAddTraits(isSelected ? .isSelected : [])
        .accessibilityLabel(isSelected ? "Selected photo" : "Photo")
    }

    @ViewBuilder
    private var selectionBadge: some View {
        ZStack {
            Circle()
                .fill(Color.primary)
                .frame(width: PickerDesign.selectionBadgeSize, height: PickerDesign.selectionBadgeSize)

            if showsSelectionOrder, let selectionIndex {
                Text("\(selectionIndex + 1)")
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(Color(.systemBackground))
            } else {
                Image(systemName: "checkmark")
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(Color(.systemBackground))
            }
        }
        .shadow(color: .black.opacity(0.2), radius: 1, y: 1)
    }

    private func reloadThumbnailIfNeeded() {
        guard cellSide > 0 else { return }

        let expectedPixelSide = cellSide * displayScale
        if let thumbnail,
           loadedTargetSide >= cellSide,
           CGFloat(max(thumbnail.width, thumbnail.height)) >= expectedPixelSide * 0.85 {
            return
        }

        loadThumbnail()
    }

    private func loadThumbnail() {
        guard cellSide > 0 else { return }

        let requestSize = targetSize
        let cacheKey = ImageCacheKey.thumbnail(assetID: asset.id, targetSize: requestSize)
        loadTask?.cancel()
        loadTask = Task {
            if let cached = await ImageCache.shared.image(for: cacheKey) {
                guard !Task.isCancelled else { return }
                await MainActor.run {
                    thumbnail = cached
                    loadedTargetSide = cellSide
                }
                return
            }

            do {
                let result = try await imageLoader.loadThumbnail(
                    for: asset,
                    targetSize: requestSize
                )
                guard !Task.isCancelled else { return }
                await ImageCache.shared.insert(result.cgImage, for: cacheKey, assetID: asset.id)
                await MainActor.run {
                    thumbnail = result.cgImage
                    loadedTargetSide = cellSide
                    isInCloud = result.isInCloud
                }
            } catch {
                // Keep placeholder on failure.
            }
        }
    }
}

#if DEBUG
#Preview("Unselected") {
    PhotoGridCell(
        asset: InstagramPhotosPreviewData.assets[0],
        cellSide: 120,
        selectionIndex: nil,
        showsSelectionOrder: true,
        imageLoader: ImageLoadingClient.preview,
        onTap: {}
    )
}

#Preview("Selected") {
    PhotoGridCell(
        asset: InstagramPhotosPreviewData.assets[1],
        cellSide: 120,
        selectionIndex: 0,
        showsSelectionOrder: true,
        imageLoader: ImageLoadingClient.preview,
        onTap: {}
    )
}

#Preview("iCloud") {
    PhotoGridCell(
        asset: InstagramPhotosPreviewData.assets.first { !$0.isLocallyAvailable }!,
        cellSide: 120,
        selectionIndex: nil,
        showsSelectionOrder: true,
        imageLoader: ImageLoadingClient.preview,
        onTap: {}
    )
}
#endif