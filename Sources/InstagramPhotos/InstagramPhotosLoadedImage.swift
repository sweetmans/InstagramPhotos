import CoreGraphics
import SwiftUI

/// A decoded photo returned by the picker or export APIs.
public struct InstagramPhotosLoadedImage: @unchecked Sendable {
    public let cgImage: CGImage
    public let scale: CGFloat
    public let metadata: [String: Any]

    public init(cgImage: CGImage, scale: CGFloat = 1, metadata: [String: Any] = [:]) {
        self.cgImage = cgImage
        self.scale = scale
        self.metadata = metadata
    }

    public var pixelWidth: Int { cgImage.width }
    public var pixelHeight: Int { cgImage.height }

    public var swiftUIImage: Image {
        Image(decorative: cgImage, scale: scale, orientation: .up)
    }
}

public typealias InstagramPhotosImage = InstagramPhotosLoadedImage