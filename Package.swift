// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "InstagramPhotos",
    platforms: [
        .iOS(.v16),
    ],
    products: [
        .library(
            name: "InstagramPhotos",
            targets: ["InstagramPhotos"]
        ),
    ],
    targets: [
        .target(
            name: "InstagramPhotos",
            dependencies: [],
            path: "Sources/InstagramPhotos",
            linkerSettings: [
                .linkedFramework("Photos"),
                .linkedFramework("PhotosUI"),
                .linkedFramework("ImageIO"),
                .linkedFramework("CoreGraphics"),
                .linkedFramework("UIKit", .when(platforms: [.iOS])),
            ]
        ),
        .testTarget(
            name: "InstagramPhotosTests",
            dependencies: ["InstagramPhotos"],
            path: "Tests/InstagramPhotosTests"
        ),
    ]
)