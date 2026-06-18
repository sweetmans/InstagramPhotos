import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

enum PickerDesign {
    static let gridColumnCount = 3
    static let gridSpacing: CGFloat = 1

    static func pixelAlignedLength(_ value: CGFloat) -> CGFloat {
        guard value > 0 else { return 0 }
        #if canImport(UIKit)
        let scale = UIScreen.main.scale
        #else
        let scale: CGFloat = 2
        #endif
        return floor(value * scale) / scale
    }

    /// Square cell side length for a given grid container width.
    static func gridCellSideLength(containerWidth: CGFloat) -> CGFloat {
        guard containerWidth > 0 else { return 0 }
        let columns = CGFloat(gridColumnCount)
        let totalSpacing = gridSpacing * (columns - 1)
        let raw = floor((containerWidth - totalSpacing) / columns)
        return pixelAlignedLength(raw)
    }

    static func gridRows(
        assets: [InstagramPhotosAsset],
        columnCount: Int = gridColumnCount
    ) -> [PhotoGridRowModel] {
        guard columnCount > 0, !assets.isEmpty else { return [] }

        return stride(from: 0, to: assets.count, by: columnCount).map { start in
            let slice = Array(assets[start..<min(start + columnCount, assets.count)])
            return PhotoGridRowModel(id: slice[0].id, assets: slice)
        }
    }

    static var fallbackContainerWidth: CGFloat {
        #if canImport(UIKit)
        pixelAlignedLength(UIScreen.main.bounds.width)
        #else
        390
        #endif
    }

    static let albumThumbnailSize: CGFloat = 56
    static let albumThumbnailCornerRadius: CGFloat = 10
    static let albumListRowSpacing: CGFloat = 12
    static let albumListRowMinHeight: CGFloat = 60
    static let albumListRowInsets = EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16)

    static let selectionBadgeSize: CGFloat = 22
    static let selectionBadgePadding: CGFloat = 6

    static let horizontalPadding: CGFloat = 16
    static let bannerVerticalPadding: CGFloat = 6
    static let headerGrabberHeight: CGFloat = 17
    static let minPreviewScale: CGFloat = 0.32
    /// Multiplier applied to preview point size so zooming stays sharp.
    static let previewZoomHeadroom: CGFloat = 4
    static let limitedBannerChromeButtonVerticalPadding: CGFloat = 8
    static let limitedBannerChromeButtonHorizontalPadding: CGFloat = 12
    static let limitedBannerChromeButtonHeight: CGFloat = 32
    /// Extra inset so liquid-glass chrome is not clipped by parent bounds.
    static let limitedBannerChromeBleedInset: CGFloat = 4
    static var limitedBannerChromeBleedInsetInsets: EdgeInsets {
        EdgeInsets(
            top: limitedBannerChromeBleedInset,
            leading: limitedBannerChromeBleedInset,
            bottom: limitedBannerChromeBleedInset,
            trailing: limitedBannerChromeBleedInset
        )
    }
    static let limitedBannerRowHeight: CGFloat = 32
    static let limitedBannerToggleHeight: CGFloat = 40
    static let limitedBannerDetailsHeight: CGFloat = 82
    static let limitedBannerExpandedSpacing: CGFloat = 4
    static let limitedBannerActionSpacing: CGFloat = 8
    static let limitedBannerExpandedBottomPadding: CGFloat = 8
    static let limitedBannerExpandedVerticalPadding: CGFloat = 4
    static let limitedBannerHorizontalInset: CGFloat = 12
    static let limitedBannerCornerRadius: CGFloat = 10

    static var gridBackground: Color { Color(.systemBackground) }
    static var chromeBackground: Color { Color(.systemGroupedBackground) }
    static var previewBackground: Color { Color(.secondarySystemBackground) }
    static var placeholderFill: Color { Color(.quaternarySystemFill) }
    static var bannerBackground: Color { Color(.tertiarySystemFill) }

    /// Hides banner details only while the header is mid-collapse; allows expansion when settled.
    static func limitedBannerDetailsReveal(
        isExpanded: Bool,
        headerCollapseProgress: CGFloat
    ) -> CGFloat {
        guard isExpanded else { return 0 }
        if headerCollapseProgress <= 0.01 || headerCollapseProgress >= 0.99 { return 1 }
        return max(0, 1 - headerCollapseProgress * 4)
    }

    /// Total height of the collapsible picker header for a given collapse state.
    static func collapsibleHeaderHeight(
        containerWidth: CGFloat,
        showsBanner: Bool,
        isBannerExpanded: Bool,
        collapseProgress: CGFloat
    ) -> CGFloat {
        let minPreviewSide = containerWidth * minPreviewScale
        let currentPreviewSide = containerWidth + (minPreviewSide - containerWidth) * collapseProgress

        let toggleHeight: CGFloat = showsBanner ? limitedBannerToggleHeight : 0
        let detailsHeight: CGFloat = showsBanner && isBannerExpanded ? limitedBannerDetailsHeight : 0
        let bannerDetailsSpacing: CGFloat = showsBanner && isBannerExpanded ? limitedBannerExpandedSpacing : 0
        let bannerDetailsReveal = showsBanner
            ? limitedBannerDetailsReveal(
                isExpanded: isBannerExpanded,
                headerCollapseProgress: collapseProgress
            )
            : 0
        let bannerHeight = toggleHeight + (detailsHeight + bannerDetailsSpacing) * bannerDetailsReveal

        return pixelAlignedLength(currentPreviewSide + bannerHeight + headerGrabberHeight)
    }
}
