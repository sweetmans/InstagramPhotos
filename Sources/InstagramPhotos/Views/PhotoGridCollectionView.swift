#if canImport(UIKit)
import SwiftUI
import UIKit

struct PhotoGridSelectionSnapshot: Equatable {
    let selectedOrderByID: [String: Int]
    let showsSelectionOrder: Bool

    init(selectedOrderByID: [String: Int], showsSelectionOrder: Bool) {
        self.selectedOrderByID = selectedOrderByID
        self.showsSelectionOrder = showsSelectionOrder
    }

    @MainActor
    init(selection: InstagramPhotosSelection) {
        showsSelectionOrder = selection.allowsMultipleSelection
        var order: [String: Int] = [:]
        for (index, asset) in selection.assets.enumerated() {
            order[asset.id] = index
        }
        selectedOrderByID = order
    }

    func selectionIndex(for assetID: String) -> Int? {
        selectedOrderByID[assetID]
    }
}

struct PhotoGridCollectionViewRepresentable: UIViewRepresentable {
    let assets: [InstagramPhotosAsset]
    let cellSide: CGFloat
    let selectionSnapshot: PhotoGridSelectionSnapshot
    let imageLoader: ImageLoadingClient
    let onAssetFocused: (InstagramPhotosAsset) -> Void
    let onToggleSelection: (InstagramPhotosAsset) -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    func makeUIView(context: Context) -> UICollectionView {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = PickerDesign.gridSpacing
        layout.minimumLineSpacing = PickerDesign.gridSpacing
        layout.sectionInset = .zero
        layout.itemSize = CGSize(width: cellSide, height: cellSide)

        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = UIColor(PickerDesign.gridBackground)
        collectionView.alwaysBounceVertical = true
        collectionView.contentInsetAdjustmentBehavior = .never
        collectionView.showsVerticalScrollIndicator = true
        collectionView.isPrefetchingEnabled = true
        collectionView.register(
            PhotoGridCollectionCell.self,
            forCellWithReuseIdentifier: PhotoGridCollectionCell.reuseID
        )

        collectionView.dataSource = context.coordinator
        collectionView.delegate = context.coordinator
        collectionView.prefetchDataSource = context.coordinator

        context.coordinator.collectionView = collectionView
        return collectionView
    }

    func updateUIView(_ collectionView: UICollectionView, context: Context) {
        let coordinator = context.coordinator
        let assetIDs = assets.map(\.id)
        let assetsChanged = coordinator.assetIDs != assetIDs
        let cellSideChanged = abs(coordinator.cellSide - cellSide) > 0.5
        let selectionChanged = coordinator.selectionSnapshot != selectionSnapshot

        coordinator.parent = self
        coordinator.assetIDs = assetIDs
        coordinator.cellSide = cellSide
        coordinator.selectionSnapshot = selectionSnapshot

        if cellSideChanged, let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.itemSize = CGSize(width: cellSide, height: cellSide)
            layout.invalidateLayout()
        }

        if assetsChanged || cellSideChanged {
            collectionView.reloadData()
        } else if selectionChanged {
            coordinator.updateVisibleSelection(in: collectionView)
        }
    }

    final class Coordinator: NSObject, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDataSourcePrefetching {
        var parent: PhotoGridCollectionViewRepresentable
        weak var collectionView: UICollectionView?
        var assetIDs: [String] = []
        var cellSide: CGFloat = 0
        var selectionSnapshot = PhotoGridSelectionSnapshot(
            selectedOrderByID: [:],
            showsSelectionOrder: false
        )

        init(parent: PhotoGridCollectionViewRepresentable) {
            self.parent = parent
            self.assetIDs = parent.assets.map(\.id)
            self.cellSide = parent.cellSide
            self.selectionSnapshot = parent.selectionSnapshot
        }

        func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            parent.assets.count
        }

        func collectionView(
            _ collectionView: UICollectionView,
            cellForItemAt indexPath: IndexPath
        ) -> UICollectionViewCell {
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: PhotoGridCollectionCell.reuseID,
                for: indexPath
            ) as! PhotoGridCollectionCell

            let asset = parent.assets[indexPath.item]
            cell.configure(
                asset: asset,
                cellSide: parent.cellSide,
                selectionIndex: selectionSnapshot.selectionIndex(for: asset.id),
                showsSelectionOrder: selectionSnapshot.showsSelectionOrder,
                imageLoader: parent.imageLoader
            )
            return cell
        }

        func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
            let asset = parent.assets[indexPath.item]
            parent.onToggleSelection(asset)
            parent.onAssetFocused(asset)
        }

        func collectionView(
            _ collectionView: UICollectionView,
            prefetchItemsAt indexPaths: [IndexPath]
        ) {
            let targetSize = CGSize(width: cellSide, height: cellSide)
            let ids = indexPaths.compactMap { indexPath -> String? in
                guard parent.assets.indices.contains(indexPath.item) else { return nil }
                return parent.assets[indexPath.item].id
            }
            guard !ids.isEmpty else { return }
            parent.imageLoader.prepareAssets(ids: ids)
            parent.imageLoader.startCaching(assetIDs: ids, targetSize: targetSize)
        }

        func collectionView(
            _ collectionView: UICollectionView,
            cancelPrefetchingForItemsAt indexPaths: [IndexPath]
        ) {
            let targetSize = CGSize(width: cellSide, height: cellSide)
            let ids = indexPaths.compactMap { indexPath -> String? in
                guard parent.assets.indices.contains(indexPath.item) else { return nil }
                return parent.assets[indexPath.item].id
            }
            guard !ids.isEmpty else { return }
            parent.imageLoader.stopCaching(assetIDs: ids, targetSize: targetSize)
        }

        func updateVisibleSelection(in collectionView: UICollectionView) {
            for case let cell as PhotoGridCollectionCell in collectionView.visibleCells {
                guard let assetID = cell.representedAssetID else { continue }
                cell.updateSelection(
                    selectionIndex: selectionSnapshot.selectionIndex(for: assetID),
                    showsSelectionOrder: selectionSnapshot.showsSelectionOrder
                )
            }
        }
    }
}

private final class PhotoGridCollectionCell: UICollectionViewCell {
    static let reuseID = "PhotoGridCollectionCell"

    private(set) var representedAssetID: String?

    private let imageView = UIImageView()
    private let selectionOverlay = UIView()
    private let badgeBackground = UIView()
    private let badgeLabel = UILabel()
    private let badgeIcon = UIImageView()
    private let cloudContainer = UIView()
    private let cloudIcon = UIImageView()

    private var loadTask: Task<Void, Never>?
    private var loadedTargetSide: CGFloat = 0

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        loadTask?.cancel()
        loadTask = nil
        representedAssetID = nil
        loadedTargetSide = 0
        imageView.image = nil
        cloudContainer.isHidden = true
        updateSelection(selectionIndex: nil, showsSelectionOrder: false)
    }

    func configure(
        asset: InstagramPhotosAsset,
        cellSide: CGFloat,
        selectionIndex: Int?,
        showsSelectionOrder: Bool,
        imageLoader: ImageLoadingClient
    ) {
        representedAssetID = asset.id
        updateSelection(selectionIndex: selectionIndex, showsSelectionOrder: showsSelectionOrder)
        reloadThumbnailIfNeeded(
            asset: asset,
            cellSide: cellSide,
            imageLoader: imageLoader
        )
    }

    func updateSelection(selectionIndex: Int?, showsSelectionOrder: Bool) {
        let isSelected = selectionIndex != nil
        selectionOverlay.isHidden = !isSelected
        badgeBackground.isHidden = !isSelected

        if isSelected {
            if showsSelectionOrder, let selectionIndex {
                badgeLabel.text = "\(selectionIndex + 1)"
                badgeLabel.isHidden = false
                badgeIcon.isHidden = true
            } else {
                badgeLabel.isHidden = true
                badgeIcon.isHidden = false
            }
        }
    }

    private func setupViews() {
        contentView.backgroundColor = UIColor(PickerDesign.placeholderFill)

        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(imageView)

        selectionOverlay.backgroundColor = UIColor.label.withAlphaComponent(0.15)
        selectionOverlay.isHidden = true
        selectionOverlay.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(selectionOverlay)

        badgeBackground.backgroundColor = .label
        badgeBackground.layer.cornerRadius = PickerDesign.selectionBadgeSize / 2
        badgeBackground.layer.shadowColor = UIColor.black.cgColor
        badgeBackground.layer.shadowOpacity = 0.2
        badgeBackground.layer.shadowRadius = 1
        badgeBackground.layer.shadowOffset = CGSize(width: 0, height: 1)
        badgeBackground.isHidden = true
        badgeBackground.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(badgeBackground)

        badgeLabel.font = .systemFont(ofSize: 11, weight: .bold)
        badgeLabel.textColor = .systemBackground
        badgeLabel.textAlignment = .center
        badgeLabel.translatesAutoresizingMaskIntoConstraints = false
        badgeBackground.addSubview(badgeLabel)

        let checkConfig = UIImage.SymbolConfiguration(pointSize: 11, weight: .bold)
        badgeIcon.image = UIImage(systemName: "checkmark", withConfiguration: checkConfig)
        badgeIcon.tintColor = .systemBackground
        badgeIcon.contentMode = .scaleAspectFit
        badgeIcon.translatesAutoresizingMaskIntoConstraints = false
        badgeBackground.addSubview(badgeIcon)

        cloudContainer.backgroundColor = UIColor.systemBackground.withAlphaComponent(0.55)
        cloudContainer.layer.cornerRadius = 11
        cloudContainer.isHidden = true
        cloudContainer.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(cloudContainer)

        let cloudConfig = UIImage.SymbolConfiguration(pointSize: 11, weight: .semibold)
        cloudIcon.image = UIImage(systemName: "icloud.and.arrow.down", withConfiguration: cloudConfig)
        cloudIcon.tintColor = .label
        cloudIcon.contentMode = .scaleAspectFit
        cloudIcon.translatesAutoresizingMaskIntoConstraints = false
        cloudContainer.addSubview(cloudIcon)

        let badgeSize = PickerDesign.selectionBadgeSize
        let badgePadding = PickerDesign.selectionBadgePadding

        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),

            selectionOverlay.topAnchor.constraint(equalTo: contentView.topAnchor),
            selectionOverlay.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            selectionOverlay.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            selectionOverlay.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),

            badgeBackground.widthAnchor.constraint(equalToConstant: badgeSize),
            badgeBackground.heightAnchor.constraint(equalToConstant: badgeSize),
            badgeBackground.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor,
                constant: -badgePadding
            ),
            badgeBackground.bottomAnchor.constraint(
                equalTo: contentView.bottomAnchor,
                constant: -badgePadding
            ),

            badgeLabel.centerXAnchor.constraint(equalTo: badgeBackground.centerXAnchor),
            badgeLabel.centerYAnchor.constraint(equalTo: badgeBackground.centerYAnchor),

            badgeIcon.centerXAnchor.constraint(equalTo: badgeBackground.centerXAnchor),
            badgeIcon.centerYAnchor.constraint(equalTo: badgeBackground.centerYAnchor),

            cloudContainer.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor,
                constant: badgePadding
            ),
            cloudContainer.bottomAnchor.constraint(
                equalTo: contentView.bottomAnchor,
                constant: -badgePadding
            ),
            cloudContainer.widthAnchor.constraint(equalToConstant: 22),
            cloudContainer.heightAnchor.constraint(equalToConstant: 22),

            cloudIcon.centerXAnchor.constraint(equalTo: cloudContainer.centerXAnchor),
            cloudIcon.centerYAnchor.constraint(equalTo: cloudContainer.centerYAnchor),
        ])
    }

    private func reloadThumbnailIfNeeded(
        asset: InstagramPhotosAsset,
        cellSide: CGFloat,
        imageLoader: ImageLoadingClient
    ) {
        guard cellSide > 0 else { return }

        let displayScale = traitCollection.displayScale
        let expectedPixelSide = cellSide * displayScale
        if let image = imageView.image,
           loadedTargetSide >= cellSide,
           CGFloat(max(image.size.width * image.scale, image.size.height * image.scale)) >= expectedPixelSide * 0.85 {
            return
        }

        loadThumbnail(asset: asset, cellSide: cellSide, imageLoader: imageLoader, displayScale: displayScale)
    }

    private func loadThumbnail(
        asset: InstagramPhotosAsset,
        cellSide: CGFloat,
        imageLoader: ImageLoadingClient,
        displayScale: CGFloat
    ) {
        guard cellSide > 0 else { return }

        let requestSize = CGSize(width: cellSide, height: cellSide)
        let cacheKey = ImageCacheKey.thumbnail(assetID: asset.id, targetSize: requestSize)
        let assetID = asset.id

        loadTask?.cancel()
        loadTask = Task { @MainActor in
            if let cached = await ImageCache.shared.image(for: cacheKey) {
                guard !Task.isCancelled, representedAssetID == assetID else { return }
                imageView.image = UIImage(cgImage: cached, scale: displayScale, orientation: .up)
                loadedTargetSide = cellSide
                return
            }

            do {
                let result = try await imageLoader.loadThumbnail(for: asset, targetSize: requestSize)
                guard !Task.isCancelled, representedAssetID == assetID else { return }
                await ImageCache.shared.insert(result.cgImage, for: cacheKey, assetID: asset.id)
                imageView.image = UIImage(
                    cgImage: result.cgImage,
                    scale: displayScale,
                    orientation: .up
                )
                loadedTargetSide = cellSide
                cloudContainer.isHidden = !result.isInCloud
            } catch {
                // Keep placeholder on failure.
            }
        }
    }
}
#endif