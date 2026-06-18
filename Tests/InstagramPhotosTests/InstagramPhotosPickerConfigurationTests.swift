import Photos
import XCTest
@testable import InstagramPhotos

final class InstagramPhotosPickerConfigurationTests: XCTestCase {
    func testEffectiveSelectionLimitSingleSelection() {
        let configuration = InstagramPhotosPickerConfiguration(
            selectionLimit: 10,
            allowsMultipleSelection: false
        )
        XCTAssertEqual(configuration.effectiveSelectionLimit, 1)
    }

    func testEffectiveSelectionLimitMultipleSelection() {
        let configuration = InstagramPhotosPickerConfiguration(
            selectionLimit: 5,
            allowsMultipleSelection: true
        )
        XCTAssertEqual(configuration.effectiveSelectionLimit, 5)
    }

    func testCanSelectAdditionalRespectsLimit() {
        let configuration = InstagramPhotosPickerConfiguration(
            selectionLimit: 2,
            allowsMultipleSelection: true
        )
        XCTAssertTrue(configuration.canSelectAdditional(count: 0))
        XCTAssertTrue(configuration.canSelectAdditional(count: 1))
        XCTAssertFalse(configuration.canSelectAdditional(count: 2))
    }
}