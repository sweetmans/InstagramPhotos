// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "InstagramPhotos",
    platforms: [.iOS(.v12)],
    products: [
        .library(
            name: "InstagramPhotosPodspec",
            targets: ["InstagramPhotosPodspec"])
    ],
    dependencies: [],
    targets: [
        .target(
            name: "InstagramPhotosPodspec",
            dependencies: [],
            path: "InstagramPhotos/InstagramPhotosPodspec",
            resources: [.process("Resources/squareMask@3x.png"),
                        .process("Resources/squareMask@2x.png")],
            linkerSettings: [.linkedFramework("UIKit", .when(platforms: [.iOS])),
                             .linkedFramework("PhotosUI", .when(platforms: [.iOS])),
                             .linkedFramework("Photos", .when(platforms: [.iOS]))])
    ]
)