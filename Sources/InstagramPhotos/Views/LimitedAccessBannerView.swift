import SwiftUI

struct LimitedAccessBannerView: View {
    let title: String
    let description: String
    let actionTitle: String
    let isExpanded: Bool
    let headerCollapseProgress: CGFloat
    let onToggle: () -> Void
    let onManageAccess: () -> Void

    private var detailsRevealProgress: CGFloat {
        PickerDesign.limitedBannerDetailsReveal(
            isExpanded: isExpanded,
            headerCollapseProgress: headerCollapseProgress
        )
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            toggleRow

            if detailsRevealProgress > 0.001 {
                expandedDetails
                    .padding(.top, PickerDesign.limitedBannerExpandedSpacing)
                    .opacity(detailsRevealProgress)
                    .frame(
                        height: PickerDesign.limitedBannerDetailsHeight * detailsRevealProgress,
                        alignment: .top
                    )
            }
        }
        .padding(.horizontal, PickerDesign.limitedBannerHorizontalInset)
        .padding(.vertical, PickerDesign.limitedBannerExpandedVerticalPadding)
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .background(bannerBackground)
    }

    private var toggleRow: some View {
        HStack(alignment: .center, spacing: 8) {
            Text(title)
                .font(.footnote.weight(.semibold))
                .foregroundStyle(.primary)
                .lineLimit(1)
                .frame(maxWidth: .infinity, alignment: .leading)

            toggleButton
        }
        .frame(height: PickerDesign.limitedBannerChromeButtonHeight, alignment: .center)
    }

    private var expandedDetails: some View {
        VStack(alignment: .leading, spacing: PickerDesign.limitedBannerActionSpacing) {
            Text(description)
                .font(.caption)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)

            manageAccessButton
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 8.0)
        }
    }

    @ViewBuilder
    private var bannerBackground: some View {
        if detailsRevealProgress > 0.001 {
            RoundedRectangle(cornerRadius: PickerDesign.limitedBannerCornerRadius, style: .continuous)
                .fill(Color(.secondarySystemGroupedBackground))
                .opacity(detailsRevealProgress)
        }
    }

    private var toggleButton: some View {
        PickerChromeIconButton(
            systemImage: isExpanded ? "chevron.up" : "chevron.down",
            accessibilityLabel: title,
            accessibilityHint: isExpanded
                ? "Collapse limited access details"
                : "Expand limited access details",
            sizing: .banner,
            action: onToggle
        )
        .frame(
            width: PickerDesign.limitedBannerChromeButtonHeight,
            height: PickerDesign.limitedBannerChromeButtonHeight
        )
    }

    private var manageAccessButton: some View {
        PickerChromeLabelButton(
            title: actionTitle,
            systemImage: "photo.badge.plus",
            accessibilityHint: "Opens the limited photo library picker",
            sizing: .banner,
            action: onManageAccess
        )
        .frame(height: PickerDesign.limitedBannerChromeButtonHeight)
    }
}

#if DEBUG
#Preview("Collapsed") {
    LimitedAccessBannerView(
        title: "Limited Access",
        description: "You've granted access to only a subset of your photo library. Choose additional photos and albums that can be used in this app.",
        actionTitle: "Add more photos",
        isExpanded: false,
        headerCollapseProgress: 0,
        onToggle: {},
        onManageAccess: {}
    )
    .background(PickerDesign.chromeBackground)
}

#Preview("Expanded") {
    LimitedAccessBannerView(
        title: "Limited Access",
        description: "You've granted access to only a subset of your photo library. Choose additional photos and albums that can be used in this app.",
        actionTitle: "Add more photos",
        isExpanded: true,
        headerCollapseProgress: 0,
        onToggle: {},
        onManageAccess: {}
    )
    .background(PickerDesign.chromeBackground)
}

#Preview("Collapsed Header Expanded Banner") {
    LimitedAccessBannerView(
        title: "Limited Access",
        description: "You've granted access to only a subset of your photo library. Choose additional photos and albums that can be used in this app.",
        actionTitle: "Add more photos",
        isExpanded: true,
        headerCollapseProgress: 1,
        onToggle: {},
        onManageAccess: {}
    )
    .background(PickerDesign.chromeBackground)
}

#Preview("Collapsing Header") {
    LimitedAccessBannerView(
        title: "Limited Access",
        description: "You've granted access to only a subset of your photo library. Choose additional photos and albums that can be used in this app.",
        actionTitle: "Add more photos",
        isExpanded: true,
        headerCollapseProgress: 0.35,
        onToggle: {},
        onManageAccess: {}
    )
    .frame(height: PickerDesign.limitedBannerToggleHeight + PickerDesign.limitedBannerDetailsHeight * 0.4)
    .clipped()
    .background(PickerDesign.chromeBackground)
}
#endif
