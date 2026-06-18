import XCTest
@testable import InstagramPhotos

final class PhotoLibraryHostRequirementsTests: XCTestCase {
    func testValidateHostInfoPlistDetectsMissingKeys() {
        let bundle = MockInfoPlistBundle(
            infoDictionary: [
                "CFBundleIdentifier": "com.example.test",
            ]
        )

        let result = PhotoLibraryHostRequirements.validateHostInfoPlist(reader: bundle)

        XCTAssertFalse(result.isValid)
        XCTAssertEqual(
            Set(result.missingKeys),
            Set([
                PhotoLibraryHostRequirements.photoLibraryUsageDescriptionKey,
                PhotoLibraryHostRequirements.preventAutomaticLimitedAccessAlertKey,
            ])
        )
    }

    func testValidateHostInfoPlistAcceptsConfiguredKeys() {
        let bundle = MockInfoPlistBundle(
            infoDictionary: [
                PhotoLibraryHostRequirements.photoLibraryUsageDescriptionKey: "Read photos",
                PhotoLibraryHostRequirements.preventAutomaticLimitedAccessAlertKey: true,
            ]
        )

        let result = PhotoLibraryHostRequirements.validateHostInfoPlist(reader: bundle)

        XCTAssertTrue(result.isValid)
        XCTAssertTrue(result.missingKeys.isEmpty)
    }
}

private struct MockInfoPlistBundle: InfoPlistReading {
    let infoDictionary: [String: Any]

    func object(forInfoDictionaryKey key: String) -> Any? {
        infoDictionary[key]
    }
}