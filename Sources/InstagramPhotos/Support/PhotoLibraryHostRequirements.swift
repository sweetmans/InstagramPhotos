import Foundation

protocol InfoPlistReading: Sendable {
    func object(forInfoDictionaryKey key: String) -> Any?
}

extension Bundle: InfoPlistReading {}

/// Required host-app Info.plist keys for a smooth photo-library experience.
public enum PhotoLibraryHostRequirements: Sendable {
    public static let photoLibraryUsageDescriptionKey = "NSPhotoLibraryUsageDescription"
    public static let preventAutomaticLimitedAccessAlertKey = "PHPhotoLibraryPreventAutomaticLimitedAccessAlert"

    public struct ValidationResult: Equatable, Sendable {
        public let missingKeys: [String]

        public var isValid: Bool { missingKeys.isEmpty }
    }

    /// Validates that the host application Info.plist includes keys required by InstagramPhotos.
    public static func validateHostInfoPlist(bundle: Bundle = .main) -> ValidationResult {
        validateHostInfoPlist(reader: bundle)
    }

    static func validateHostInfoPlist(reader: some InfoPlistReading) -> ValidationResult {
        let requiredKeys = [
            photoLibraryUsageDescriptionKey,
            preventAutomaticLimitedAccessAlertKey,
        ]

        let missingKeys = requiredKeys.filter { key in
            guard let value = reader.object(forInfoDictionaryKey: key) else { return true }
            if let string = value as? String {
                return string.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            }
            return false
        }

        return ValidationResult(missingKeys: missingKeys)
    }

    static func logMissingRequirementsIfNeeded(
        for status: InstagramPhotosAuthorizationStatus,
        bundle: Bundle = .main
    ) {
        #if DEBUG
        guard status == .limited else { return }

        let validation = validateHostInfoPlist(bundle: bundle)
        guard !validation.isValid else { return }

        let keys = validation.missingKeys.joined(separator: ", ")
        print(
            """
            InstagramPhotos warning: Missing host Info.plist keys: \(keys).
            Users with Limited Photos access may see a system photo-access sheet every time the picker opens.
            Add the keys to your app target's Info.plist (not the Swift package).
            """
        )
        #endif
    }
}