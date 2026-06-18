import SwiftUI

enum PickerChromeButtonSizing {
    case toolbar
    case banner

    var labelImageScale: Image.Scale {
        switch self {
        case .toolbar: .small
        case .banner: .large
        }
    }

    var iconImageScale: Image.Scale {
        switch self {
        case .toolbar: .medium
        case .banner: .large
        }
    }

    var iconFont: Font {
        switch self {
        case .toolbar: .body
        case .banner: .body.weight(.semibold)
        }
    }

    var iconPadding: EdgeInsets {
        switch self {
        case .toolbar:
            EdgeInsets(top: 3, leading: 3, bottom: 3, trailing: 3)
        case .banner:
            EdgeInsets(
                top: PickerDesign.limitedBannerChromeButtonVerticalPadding,
                leading: PickerDesign.limitedBannerChromeButtonVerticalPadding,
                bottom: PickerDesign.limitedBannerChromeButtonVerticalPadding,
                trailing: PickerDesign.limitedBannerChromeButtonVerticalPadding
            )
        }
    }

    var labelPadding: EdgeInsets {
        switch self {
        case .toolbar:
            EdgeInsets(top: 3, leading: 3, bottom: 3, trailing: 3)
        case .banner:
            EdgeInsets(
                top: 0,
                leading: PickerDesign.limitedBannerChromeButtonHorizontalPadding,
                bottom: 0,
                trailing: PickerDesign.limitedBannerChromeButtonHorizontalPadding
            )
        }
    }

    var fixedHeight: CGFloat? {
        switch self {
        case .toolbar: nil
        case .banner: PickerDesign.limitedBannerChromeButtonHeight
        }
    }

    var usesSmallControlSize: Bool {
        switch self {
        case .toolbar: false
        case .banner: true
        }
    }
}

/// Icon-only control styled like navigation bar toolbar buttons (liquid glass circle on iOS 26+).
struct PickerChromeIconButton: View {
    let systemImage: String
    let accessibilityLabel: String
    var accessibilityHint: String?
    var sizing: PickerChromeButtonSizing = .toolbar
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .font(sizing.iconFont)
                .imageScale(sizing.iconImageScale)
                .padding(sizing.iconPadding)
        }
        .modifier(PickerChromeIconButtonStyle(sizing: sizing))
        .accessibilityLabel(accessibilityLabel)
        .accessibilityHint(accessibilityHint ?? "")
    }
}

/// Text + icon control styled like navigation bar toolbar buttons (liquid glass capsule on iOS 26+).
struct PickerChromeLabelButton: View {
    let title: String
    let systemImage: String
    var accessibilityHint: String?
    var sizing: PickerChromeButtonSizing = .toolbar
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Label {
                Text(title)
                    .font(sizing == .banner ? .caption.weight(.semibold) : .caption.weight(.semibold))
                    .lineLimit(1)
            } icon: {
                Image(systemName: systemImage)
                    .font(sizing == .banner ? .caption.weight(.semibold) : .caption.weight(.semibold))
                    .imageScale(sizing.labelImageScale)
            }
            .padding(sizing.labelPadding)
            .frame(height: sizing.fixedHeight)
        }
        .modifier(PickerChromeLabelButtonStyle(sizing: sizing))
        .padding(sizing == .banner ? PickerDesign.limitedBannerChromeBleedInsetInsets : EdgeInsets())
        .accessibilityLabel(title)
        .accessibilityHint(accessibilityHint ?? "")
    }
}

private struct PickerChromeIconButtonStyle: ViewModifier {
    let sizing: PickerChromeButtonSizing

    func body(content: Content) -> some View {
        let controlSize: ControlSize = sizing.usesSmallControlSize ? .small : .mini

        if #available(iOS 26.0, *) {
            content
                .buttonStyle(.glass)
                .controlSize(controlSize)
                .buttonBorderShape(.circle)
                .labelStyle(.iconOnly)
        } else if #available(iOS 17.0, *) {
            content
                .buttonStyle(.bordered)
                .controlSize(controlSize)
                .buttonBorderShape(.circle)
                .labelStyle(.iconOnly)
        } else {
            content
                .buttonStyle(.bordered)
                .controlSize(controlSize)
                .labelStyle(.iconOnly)
                .clipShape(Circle())
        }
    }
}

private struct PickerChromeLabelButtonStyle: ViewModifier {
    let sizing: PickerChromeButtonSizing

    func body(content: Content) -> some View {
        let controlSize: ControlSize = sizing == .banner ? .mini : .small

        if #available(iOS 26.0, *) {
            content
                .buttonStyle(.glass)
                .controlSize(controlSize)
                .buttonBorderShape(.capsule)
                .labelStyle(.titleAndIcon)
        } else if #available(iOS 17.0, *) {
            content
                .buttonStyle(.bordered)
                .controlSize(controlSize)
                .buttonBorderShape(.capsule)
                .labelStyle(.titleAndIcon)
        } else {
            content
                .buttonStyle(.bordered)
                .controlSize(controlSize)
                .labelStyle(.titleAndIcon)
        }
    }
}

#if DEBUG
#Preview("Banner Chrome Buttons") {
    HStack(alignment: .center, spacing: 12) {
        PickerChromeIconButton(
            systemImage: "chevron.down",
            accessibilityLabel: "Expand",
            sizing: .banner,
            action: {}
        )
        .frame(
            width: PickerDesign.limitedBannerChromeButtonHeight,
            height: PickerDesign.limitedBannerChromeButtonHeight
        )

        PickerChromeLabelButton(
            title: "Add more photos",
            systemImage: "photo.badge.plus",
            sizing: .banner,
            action: {}
        )
        .frame(height: PickerDesign.limitedBannerChromeButtonHeight)
    }
    .padding()
    .background(PickerDesign.chromeBackground)
}
#endif