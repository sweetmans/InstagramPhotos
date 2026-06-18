import SwiftUI

struct LoadingProgressView: View {
    let progress: Double
    let label: String

    var body: some View {
        VStack(spacing: 12) {
            ProgressView(value: progress)
                .progressViewStyle(.linear)
                .tint(.primary)
            Text(label)
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .padding(16)
        .frame(maxWidth: 240)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
        .accessibilityElement(children: .combine)
        .accessibilityLabel(label)
        .accessibilityValue("\(Int(progress * 100)) percent")
    }
}

#if DEBUG
#Preview("Downloading") {
    ZStack {
        PickerDesign.previewBackground
        LoadingProgressView(progress: 0.42, label: "Downloading from iCloud…")
    }
}

#Preview("Complete") {
    ZStack {
        PickerDesign.previewBackground
        LoadingProgressView(progress: 1, label: "Downloading from iCloud…")
    }
}
#endif