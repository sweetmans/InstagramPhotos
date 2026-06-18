import InstagramPhotos
import SwiftUI

@main
struct SwiftUIDemoApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

struct ContentView: View {
    @State private var isPresented = false
    @State private var selection: [InstagramPhotosAsset] = []
    @State private var loadedImages: [InstagramPhotosLoadedImage] = []
    @State private var isLoadingImages = false
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                if loadedImages.isEmpty {
                    VStack(spacing: 8) {
                        Image(systemName: "photo.on.rectangle.angled")
                            .font(.system(size: 40))
                            .foregroundStyle(.secondary)
                        Text("No Photos Selected")
                            .font(.headline)
                        Text("Tap Pick Photos to open the Instagram-style picker.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding()
                } else {
                    ScrollView(.horizontal) {
                        HStack(spacing: 12) {
                            ForEach(Array(loadedImages.enumerated()), id: \.offset) { _, image in
                                image.swiftUIImage
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 120, height: 120)
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                            }
                        }
                        .padding()
                    }
                }

                if let errorMessage {
                    Text(errorMessage)
                        .font(.footnote)
                        .foregroundStyle(.red)
                }

                Button("Pick Photos") {
                    isPresented = true
                }
                .buttonStyle(.borderedProminent)

                if !selection.isEmpty {
                    Button(isLoadingImages ? "Loading…" : "Load Images") {
                        loadSelectedImages()
                    }
                    .buttonStyle(.bordered)
                    .disabled(isLoadingImages)
                }
            }
            .navigationTitle("InstagramPhotos Demo")
            .sheet(isPresented: $isPresented) {
                InstagramPhotosPicker(
                    selection: $selection,
                    configuration: .init(
                        selectionLimit: 10,
                        allowsMultipleSelection: true,
                        iCloudNetworkAccessAllowed: true
                    )
                )
            }
        }
    }

    private func loadSelectedImages() {
        isLoadingImages = true
        errorMessage = nil

        Task {
            do {
                loadedImages = try await selection.loadImages(
                    configuration: .init(iCloudNetworkAccessAllowed: true)
                )
            } catch {
                errorMessage = error.localizedDescription
            }
            isLoadingImages = false
        }
    }
}