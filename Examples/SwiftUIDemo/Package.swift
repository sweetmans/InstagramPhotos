// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "SwiftUIDemo",
    platforms: [.iOS(.v16)],
    products: [
        .executable(name: "SwiftUIDemo", targets: ["SwiftUIDemo"]),
    ],
    dependencies: [
        .package(path: "../.."),
    ],
    targets: [
        .executableTarget(
            name: "SwiftUIDemo",
            dependencies: [
                .product(name: "InstagramPhotos", package: "InstagramPhotos"),
            ],
            path: "Sources"
        ),
    ]
)