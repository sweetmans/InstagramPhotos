# InstagramPhotos

A modern SwiftUI photo picker library with Instagram-style album browsing, preview, selection, and iCloud Photos support.

<p align="center">
  <img src="https://github.com/sweetmans/InstagramPhotos/blob/develop/Assets/banner.png" alt="InstagramPhotos">
</p>

## Overview

InstagramPhotos is a local Apple Photos picker — not an Instagram API client. Version 3 modernizes the original UIKit library into a SwiftUI-first package while preserving the familiar Instagram-like UX:

- Album grid and photo grid
- Large zoomable preview with square crop region
- Recent / all photos browsing
- Single and multiple selection
- Limited Photos access handling
- iCloud download progress UI
- Localization support

## Requirements

- iOS 16.0+
- Xcode 15.0+
- Swift 5.9+
- SwiftUI-first API with UIKit-backed photo grid for smooth scrolling

Add to your app's `Info.plist`:

```xml
<key>NSPhotoLibraryUsageDescription</key>
<string>This app needs access to your photo library.</string>
<key>PHPhotoLibraryPreventAutomaticLimitedAccessAlert</key>
<true/>
```

## Installation

### Swift Package Manager (recommended)

```swift
dependencies: [
    .package(url: "https://github.com/sweetmans/InstagramPhotos.git", from: "3.0.0")
]
```

```swift
.target(
    name: "YourApp",
    dependencies: [
        .product(name: "InstagramPhotos", package: "InstagramPhotos"),
    ]
)
```

## Quick Start

```swift
import SwiftUI
import InstagramPhotos

struct ContentView: View {
    @State private var isPresented = false
    @State private var selection: [InstagramPhotosAsset] = []

    var body: some View {
        Button("Pick Photos") {
            isPresented = true
        }
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
```

### Load full-size images

```swift
let images = try await selection.loadImages(
    configuration: .init(iCloudNetworkAccessAllowed: true)
)

for loaded in images {
    loaded.swiftUIImage // SwiftUI Image
    loaded.cgImage      // Core Graphics image data
}
```

### Configuration

```swift
InstagramPhotosPickerConfiguration(
    selectionLimit: 10,
    allowedMediaTypes: [.image],
    allowsMultipleSelection: true,
    thumbnailSize: CGSize(width: 300, height: 300),
    preferredAlbumIdentifier: nil,
    iCloudNetworkAccessAllowed: true,
    showsProgress: true,
    localizationProvider: InstagramPhotosEnglishLocalizationProvider()
)
```

## iCloud Photos Support

When `iCloudNetworkAccessAllowed` is `true` (default):

- The library detects assets that are not stored locally.
- PhotoKit requests use `PHImageRequestOptions.isNetworkAccessAllowed = true`.
- A progress overlay appears while iCloud assets download.
- Requests respect Swift task cancellation.
- Failures surface as `InstagramPhotosImageLoadingError` without blocking the main thread.

Set `iCloudNetworkAccessAllowed` to `false` if you only want on-device assets.

## Limited Photos Access

The picker handles all authorization states:

| Status | Behavior |
|--------|----------|
| `.authorized` | Full library browsing and album switching |
| `.limited` | Shows authorized photos, banner, and "Access more photos" action |
| `.denied` / `.restricted` | SwiftUI permission empty state |
| `.notDetermined` | Shows an in-picker permission screen; user taps Allow Access |

**Important:** Add `PHPhotoLibraryPreventAutomaticLimitedAccessAlert` to your **app target's** Info.plist. Without it, iOS shows a system "Select Photos" sheet every time the picker accesses PhotoKit under Limited Photos access. The Swift package cannot set this for you.

Do not call `PHPhotoLibrary.requestAuthorization` in your app immediately before presenting `InstagramPhotosPicker`. Check `InstagramPhotosAuthorizationStatus.current` first, or let the picker handle permission.

When access is limited, the picker opens the app's Settings page so users can manage photo permissions (no UIKit bridge required).

## Localization

Provide a custom localization type conforming to `InstagramPhotosLocalizationProviding`:

```swift
struct KoreanLocalizationProvider: InstagramPhotosLocalizationProviding {
    func pickerNavigationTitle() -> String { "사진 선택" }
    func pickerNavigationNextButtonText() -> String { "다음" }
    func pickerDefaultAlbumName() -> String { "모든 사진" }
    func pickerAddingImageAccessButtonText() -> String { "더 많은 사진 허용" }
    func albumNavigationTitle() -> String { "앨범 선택" }
    func albumNavigationCancelButtonText() -> String { "취소" }
    func photosLimitedAccessModeText() -> String { "허용된 사진만 표시됩니다" }
}
```

Built-in providers: `InstagramPhotosEnglishLocalizationProvider`, `InstagramPhotosChineseLocalizationProvider`.

## Migration from UIKit (v2)

| UIKit (v2) | SwiftUI (v3) |
|------------|--------------|
| `InstagramPhotosPickingViewController` | `InstagramPhotosPicker` |
| `InstagramPhotosPicking` delegate | `Binding<[InstagramPhotosAsset]>` or `onFinish` |
| `InstagramPhotos` result type | `InstagramPhotosAsset` + `loadImages()` |
| `InstagramPhotosLocalizationsProviding` | `InstagramPhotosLocalizationProviding` |
| `InstagramPhotosAlbumsProvider` | `PhotosLibraryClient` (internal) |
| Present from `UIViewController` | `.sheet` / `.fullScreenCover` |
| XIB-based UIKit views | SwiftUI views in `Sources/InstagramPhotos/Views/` |

The v2 UIKit/XIB implementation has been removed. Use the SwiftUI API above.

## Demo

### Xcode project (recommended)

```bash
open InstagramPhotos/InstagramPhotos.xcodeproj
```

Run the **InstagramPhotosApps** scheme on a simulator or device.

### Swift Package example

```bash
open Examples/SwiftUIDemo
```

## Architecture

```
Sources/InstagramPhotos/
├── InstagramPhotosPicker.swift
├── InstagramPhotosPickerConfiguration.swift
├── InstagramPhotosAsset.swift
├── InstagramPhotosSelection.swift
├── PhotosAuthorizationClient.swift
├── PhotosLibraryClient.swift
├── ImageLoadingClient.swift
├── Views/
└── Support/
```

## Testing

```bash
swift test
```

Unit tests cover configuration, selection logic, asset identity, and authorization state handling.

## License

MIT License. See [LICENSE](LICENSE).

## About

Powered by SWEETMAN, INC.