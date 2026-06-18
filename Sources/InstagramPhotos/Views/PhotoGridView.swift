import SwiftUI

struct PhotoGridView: View {
    let assets: [InstagramPhotosAsset]
    let cellSide: CGFloat
    let configuration: InstagramPhotosPickerConfiguration
    @ObservedObject var selection: InstagramPhotosSelection
    let imageLoader: ImageLoadingClient
    let onAssetFocused: (InstagramPhotosAsset) -> Void

    private var selectionSnapshot: PhotoGridSelectionSnapshot {
        PhotoGridSelectionSnapshot(selection: selection)
    }

    var body: some View {
        #if canImport(UIKit)
        PhotoGridCollectionViewRepresentable(
            assets: assets,
            cellSide: cellSide,
            selectionSnapshot: selectionSnapshot,
            imageLoader: imageLoader,
            onAssetFocused: onAssetFocused,
            onToggleSelection: handleToggleSelection
        )
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(PickerDesign.gridBackground)
        #else
        Text("Photo grid is unavailable on this platform.")
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        #endif
    }

    private func handleToggleSelection(_ asset: InstagramPhotosAsset) {
        if selection.allowsMultipleSelection {
            selection.toggle(asset)
        } else {
            selection.focus(asset)
        }
    }
}

#if DEBUG
#Preview("Empty Selection") {
    InstagramPhotosPreviewHostFactory.photoGrid(
        selection: InstagramPhotosSelection(configuration: InstagramPhotosPreviewData.configuration)
    )
}

#Preview("With Selection") {
    InstagramPhotosPreviewHostFactory.photoGrid(
        selection: InstagramPhotosPreviewData.makeSelection(selectedCount: 3)
    )
}
#endif