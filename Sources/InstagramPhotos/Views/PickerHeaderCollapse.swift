import SwiftUI

enum PickerHeaderSwipeDirection {
    case up
    case down
}

struct PickerCollapsibleHeader<Preview: View, Banner: View>: View {
    let containerWidth: CGFloat
    let showsBanner: Bool
    let isBannerExpanded: Bool
    let collapseProgress: CGFloat
    let localization: any InstagramPhotosLocalizationProviding
    let onCollapseSwipe: (PickerHeaderSwipeDirection) -> Void
    @ViewBuilder let preview: (_ side: CGFloat) -> Preview
    @ViewBuilder let banner: () -> Banner

    private var grabberHeight: CGFloat { PickerDesign.headerGrabberHeight }
    private var toggleHeight: CGFloat { showsBanner ? PickerDesign.limitedBannerToggleHeight : 0 }
    private var detailsHeight: CGFloat {
        showsBanner && isBannerExpanded ? PickerDesign.limitedBannerDetailsHeight : 0
    }

    private var bannerDetailsSpacing: CGFloat {
        showsBanner && isBannerExpanded ? PickerDesign.limitedBannerExpandedSpacing : 0
    }

    private var bannerDetailsReveal: CGFloat {
        guard showsBanner else { return 0 }
        return PickerDesign.limitedBannerDetailsReveal(
            isExpanded: isBannerExpanded,
            headerCollapseProgress: collapseProgress
        )
    }

    private var bannerHeight: CGFloat {
        toggleHeight + (detailsHeight + bannerDetailsSpacing) * bannerDetailsReveal
    }

    private var minPreviewSide: CGFloat { containerWidth * PickerDesign.minPreviewScale }

    private var currentPreviewSide: CGFloat {
        containerWidth + (minPreviewSide - containerWidth) * collapseProgress
    }

    private var visibleHeight: CGFloat {
        PickerDesign.collapsibleHeaderHeight(
            containerWidth: containerWidth,
            showsBanner: showsBanner,
            isBannerExpanded: isBannerExpanded,
            collapseProgress: collapseProgress
        )
    }

    var body: some View {
        VStack(spacing: 0) {
            preview(currentPreviewSide)
                .frame(width: currentPreviewSide, height: currentPreviewSide)
                .frame(maxWidth: .infinity)
                .frame(height: currentPreviewSide, alignment: .top)
                .clipped()
                .contentShape(Rectangle())
                .gesture(collapseSwipeGesture)

            if showsBanner {
                banner()
                    .frame(height: bannerHeight, alignment: .top)
            }

            headerGrabber
                .gesture(collapseSwipeGesture)
        }
        .frame(height: visibleHeight, alignment: .top)
        .clipped()
    }

    private var headerGrabber: some View {
        VStack(spacing: 0) {
            Capsule()
                .fill(Color.secondary.opacity(0.35))
                .frame(width: 32, height: 4)
                .padding(.top, 6)
                .padding(.bottom, 6)
        }
        .frame(maxWidth: .infinity)
        .frame(height: grabberHeight)
        .contentShape(Rectangle())
        .accessibilityElement(children: .combine)
        .accessibilityLabel(localization.pickerCollapseHeaderAccessibilityLabel())
        .accessibilityHint(localization.pickerCollapseHeaderAccessibilityHint(isCollapsed: collapseProgress > 0.5))
    }

    private var collapseSwipeGesture: some Gesture {
        DragGesture(minimumDistance: 24)
            .onEnded { value in
                let vertical = value.translation.height
                guard abs(vertical) > abs(value.translation.width) else { return }

                if vertical < -40 {
                    onCollapseSwipe(.up)
                } else if vertical > 40 {
                    onCollapseSwipe(.down)
                }
            }
    }
}