import SwiftUI

/// SwiftUI photo picker with Instagram-style album browsing, preview, and iCloud support.
public struct InstagramPhotosPicker: View {
    @Binding private var selection: [InstagramPhotosAsset]
    private let configuration: InstagramPhotosPickerConfiguration
    private let onCancel: (() -> Void)?
    private let onFinish: ((InstagramPhotosPickerFinishResult) -> Void)?

    @Environment(\.dismiss) private var dismiss

    /// Creates a picker bound to a selected asset array.
    public init(
        selection: Binding<[InstagramPhotosAsset]>,
        configuration: InstagramPhotosPickerConfiguration = .init(),
        onCancel: (() -> Void)? = nil,
        onFinish: ((InstagramPhotosPickerFinishResult) -> Void)? = nil
    ) {
        _selection = selection
        self.configuration = configuration
        self.onCancel = onCancel
        self.onFinish = onFinish
    }

    public var body: some View {
        PickerRootView(
            selection: $selection,
            configuration: configuration,
            onCancel: {
                onCancel?()
                dismiss()
            },
            onFinish: { result in
                onFinish?(result)
                dismiss()
            }
        )
        .interactiveDismissDisabled(true)
    }
}

// MARK: - Selection object convenience

public extension InstagramPhotosPicker {
    /// Creates a picker driven by an ``InstagramPhotosSelection`` observable object.
    init(
        selectionObject: InstagramPhotosSelection,
        configuration: InstagramPhotosPickerConfiguration = .init(),
        onCancel: (() -> Void)? = nil,
        onFinish: ((InstagramPhotosPickerFinishResult) -> Void)? = nil
    ) {
        self.init(
            selection: Binding(
                get: { selectionObject.assets },
                set: { selectionObject.replaceAll(with: $0) }
            ),
            configuration: configuration,
            onCancel: onCancel,
            onFinish: onFinish
        )
    }
}

#if DEBUG
#Preview("Authorized") {
    InstagramPhotosPreviewHostFactory.pickerRoot(state: .authorized)
}

#Preview("Limited") {
    InstagramPhotosPreviewHostFactory.pickerRoot(state: .limited)
}

#Preview("Denied") {
    InstagramPhotosPreviewHostFactory.pickerRoot(state: .denied)
}
#endif