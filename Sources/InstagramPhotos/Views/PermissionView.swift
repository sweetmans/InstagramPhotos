import SwiftUI

struct PermissionView: View {
    let status: InstagramPhotosAuthorizationStatus
    let localization: any InstagramPhotosLocalizationProviding
    let onRequestAccess: () -> Void
    let onManageLimitedAccess: () -> Void
    let onOpenSettings: () -> Void

    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: iconName)
                .font(.system(size: 56, weight: .light))
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(.secondary)
                .accessibilityHidden(true)

            VStack(spacing: 8) {
                Text(title)
                    .font(.title2.weight(.semibold))
                    .multilineTextAlignment(.center)

                Text(message)
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, 32)

            actionButtons
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(PickerDesign.chromeBackground)
    }

    @ViewBuilder
    private var actionButtons: some View {
        switch status {
        case .limited:
            VStack(spacing: 12) {
                Button(localization.pickerAddingImageAccessButtonText()) {
                    onManageLimitedAccess()
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)

                Button(localization.permissionOpenSettingsButtonText()) {
                    onOpenSettings()
                }
                .buttonStyle(.bordered)
                .controlSize(.large)
            }
        case .denied, .restricted:
            Button(localization.permissionOpenSettingsButtonText()) {
                onOpenSettings()
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
        case .notDetermined:
            Button(localization.permissionRequestAccessButtonText()) {
                onRequestAccess()
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
        default:
            EmptyView()
        }
    }

    private var iconName: String {
        switch status {
        case .denied, .restricted: return "photo.on.rectangle.angled"
        case .limited: return "photo.badge.plus"
        default: return "photo.on.rectangle"
        }
    }

    private var title: String {
        switch status {
        case .denied: return localization.permissionDeniedTitle()
        case .restricted: return localization.permissionRestrictedTitle()
        case .limited: return localization.photosLimitedAccessTitle()
        case .notDetermined: return localization.pickerNavigationTitle()
        default: return localization.pickerNavigationTitle()
        }
    }

    private var message: String {
        switch status {
        case .denied: return localization.permissionDeniedMessage()
        case .restricted: return localization.permissionRestrictedMessage()
        case .limited: return localization.photosLimitedAccessModeText()
        case .notDetermined: return localization.permissionNotDeterminedMessage()
        default: return localization.permissionDeniedMessage()
        }
    }
}

#if DEBUG
#Preview("Not Determined") {
    PermissionView(
        status: .notDetermined,
        localization: InstagramPhotosPreviewData.configuration.localizationProvider,
        onRequestAccess: {},
        onManageLimitedAccess: {},
        onOpenSettings: {}
    )
}

#Preview("Denied") {
    PermissionView(
        status: .denied,
        localization: InstagramPhotosPreviewData.configuration.localizationProvider,
        onRequestAccess: {},
        onManageLimitedAccess: {},
        onOpenSettings: {}
    )
}

#Preview("Limited") {
    PermissionView(
        status: .limited,
        localization: InstagramPhotosPreviewData.configuration.localizationProvider,
        onRequestAccess: {},
        onManageLimitedAccess: {},
        onOpenSettings: {}
    )
}

#Preview("Restricted") {
    PermissionView(
        status: .restricted,
        localization: InstagramPhotosPreviewData.configuration.localizationProvider,
        onRequestAccess: {},
        onManageLimitedAccess: {},
        onOpenSettings: {}
    )
}
#endif