import Photos

extension PHAsset {
    /// Maps a fetched asset using only properties available from the fetch result.
    /// Avoids `PHAssetResource` and other original-metadata lookups that degrade scrolling performance.
    func makeLightweightAsset() -> InstagramPhotosAsset {
        InstagramPhotosAsset(
            id: localIdentifier,
            mediaType: mediaType,
            pixelWidth: pixelWidth,
            pixelHeight: pixelHeight,
            creationDate: creationDate,
            isLocallyAvailable: true
        )
    }

    /// Reads dimensions and metadata off the main actor. Call only from background contexts.
    func makeDetailedAsset(isLocallyAvailable: Bool? = nil) -> InstagramPhotosAsset {
        InstagramPhotosAsset(
            id: localIdentifier,
            mediaType: mediaType,
            pixelWidth: pixelWidth,
            pixelHeight: pixelHeight,
            creationDate: creationDate,
            isLocallyAvailable: isLocallyAvailable ?? true
        )
    }
}

enum PHAssetCloudStatus {
    static func isInCloud(info: [AnyHashable: Any]?) -> Bool {
        (info?[PHImageResultIsInCloudKey] as? Bool) ?? false
    }
}