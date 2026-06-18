import SwiftUI

private struct ContainerWidthPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0

    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

/// Reads container width once per meaningful layout change to avoid GeometryReader feedback loops.
struct ContainerWidthReader: View {
    @Binding var width: CGFloat

    var body: some View {
        GeometryReader { geometry in
            Color.clear
                .preference(
                    key: ContainerWidthPreferenceKey.self,
                    value: PickerDesign.pixelAlignedLength(geometry.size.width)
                )
        }
    }
}

extension View {
    func onContainerWidthChange(_ width: Binding<CGFloat>) -> some View {
        background(ContainerWidthReader(width: width))
            .onPreferenceChange(ContainerWidthPreferenceKey.self) { newWidth in
                guard newWidth > 0 else { return }
                guard abs(newWidth - width.wrappedValue) > 0.5 else { return }
                width.wrappedValue = newWidth
            }
    }
}