import InstagramPhotos
import SwiftUI

struct ContentView: View {
    @State private var isPickerPresented = false
    @State private var selection: [InstagramPhotosAsset] = []
    @State private var loadedImages: [InstagramPhotosLoadedImage] = []
    @State private var isLoadingImages = false
    @State private var statusMessage: String?

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                if loadedImages.isEmpty {
                    placeholder
                } else {
                    selectedImagesPreview
                }

                if let statusMessage {
                    Text(statusMessage)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }

                Button("Pick Photos") {
                    isPickerPresented = true
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)

                if !selection.isEmpty {
                    Button(isLoadingImages ? "Loading…" : "Load Selected Images") {
                        loadSelectedImages()
                    }
                    .buttonStyle(.bordered)
                    .disabled(isLoadingImages)
                }
            }
            .padding()
            .background(Color(.systemGroupedBackground))
            .navigationTitle("InstagramPhotos")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $isPickerPresented) {
                InstagramPhotosPicker(
                    selection: $selection,
                    configuration: .init(
                        selectionLimit: 10,
                        allowsMultipleSelection: true,
                        iCloudNetworkAccessAllowed: true,
                        localizationProvider: InstagramPhotosEnglishLocalizationProvider()
                    ),
                    onFinish: { result in
                        statusMessage = "Selected \(result.assets.count) photo(s)"
                    }
                )
            }
        }
    }

    private var placeholder: some View {
        VStack(spacing: 12) {
            Image(systemName: "photo.on.rectangle.angled")
                .font(.system(size: 48, weight: .light))
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(.secondary)
            Text("No Photos Selected")
                .font(.title3.weight(.semibold))
            Text("Tap Pick Photos to choose images from your library.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var selectedImagesPreview: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(Array(loadedImages.enumerated()), id: \.offset) { _, image in
                    image.swiftUIImage
                        .resizable()
                        .scaledToFill()
                        .frame(width: 120, height: 120)
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                }
            }
            .padding(.vertical, 4)
        }
    }

    private func loadSelectedImages() {
        isLoadingImages = true
        statusMessage = nil

        Task {
            do {
                loadedImages = try await selection.loadImages(
                    configuration: .init(iCloudNetworkAccessAllowed: true)
                )
                statusMessage = "Loaded \(loadedImages.count) image(s)"
            } catch {
                statusMessage = error.localizedDescription
            }
            isLoadingImages = false
        }
    }
}

#Preview {
    ContentView()
}