import Foundation

struct PhotoGridRowModel: Identifiable, Equatable, Sendable {
    let id: String
    let assets: [InstagramPhotosAsset]
}