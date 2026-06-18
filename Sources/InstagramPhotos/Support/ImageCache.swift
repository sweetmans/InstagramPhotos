import CoreGraphics
import Foundation

enum ImageCacheKey {
    static func thumbnail(assetID: String, targetSize: CGSize) -> String {
        "\(assetID)-\(Int(targetSize.width))x\(Int(targetSize.height))"
    }
}

actor ImageCache {
    static let shared = ImageCache()

    private let cache = NSCache<NSString, CGImage>()
    private var assetKeys: [String: String] = [:]

    init() {
        cache.countLimit = 300
        cache.totalCostLimit = 64 * 1024 * 1024
    }

    func image(for key: String) -> CGImage? {
        cache.object(forKey: key as NSString)
    }

    func imageForAssetID(_ assetID: String) -> CGImage? {
        guard let key = assetKeys[assetID] else { return nil }
        return image(for: key)
    }

    func insert(_ image: CGImage, for key: String, assetID: String? = nil) {
        let cost = image.bytesPerRow * image.height
        cache.setObject(image, forKey: key as NSString, cost: cost)
        if let assetID {
            assetKeys[assetID] = key
        }
    }

    func remove(for key: String) {
        cache.removeObject(forKey: key as NSString)
    }

    func removeAll() {
        cache.removeAllObjects()
        assetKeys.removeAll()
    }
}