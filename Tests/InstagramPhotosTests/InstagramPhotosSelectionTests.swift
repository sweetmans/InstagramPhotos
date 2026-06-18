import XCTest
@testable import InstagramPhotos

@MainActor
final class InstagramPhotosSelectionTests: XCTestCase {
    func makeAsset(id: String) -> InstagramPhotosAsset {
        InstagramPhotosAsset(
            id: id,
            mediaType: .image,
            pixelWidth: 100,
            pixelHeight: 100,
            creationDate: nil,
            isLocallyAvailable: true
        )
    }

    func testToggleAddsAndRemovesAsset() {
        let configuration = InstagramPhotosPickerConfiguration(
            selectionLimit: 3,
            allowsMultipleSelection: true
        )
        let selection = InstagramPhotosSelection(configuration: configuration)
        let asset = makeAsset(id: "a")

        selection.toggle(asset)
        XCTAssertEqual(selection.assets, [asset])

        selection.toggle(asset)
        XCTAssertTrue(selection.isEmpty)
    }

    func testSelectionLimitBlocksAdditionalAssets() {
        let configuration = InstagramPhotosPickerConfiguration(
            selectionLimit: 2,
            allowsMultipleSelection: true
        )
        let selection = InstagramPhotosSelection(configuration: configuration)
        let first = makeAsset(id: "1")
        let second = makeAsset(id: "2")
        let third = makeAsset(id: "3")

        selection.toggle(first)
        selection.toggle(second)
        selection.toggle(third)

        XCTAssertEqual(selection.assets.count, 2)
        XCTAssertFalse(selection.assets.contains(third))
    }

    func testFocusReplacesSelectionInSingleSelectionMode() {
        let configuration = InstagramPhotosPickerConfiguration(allowsMultipleSelection: false)
        let selection = InstagramPhotosSelection(configuration: configuration)
        let first = makeAsset(id: "1")
        let second = makeAsset(id: "2")

        selection.focus(first)
        selection.focus(second)

        XCTAssertEqual(selection.assets, [second])
        XCTAssertEqual(selection.focusedAsset, second)
    }

    func testSetAllowsMultipleSelectionCollapsesToFocusedAsset() {
        let configuration = InstagramPhotosPickerConfiguration(
            selectionLimit: 5,
            allowsMultipleSelection: true
        )
        let selection = InstagramPhotosSelection(configuration: configuration)
        let first = makeAsset(id: "1")
        let second = makeAsset(id: "2")

        selection.toggle(first)
        selection.toggle(second)
        selection.focus(second)

        selection.setAllowsMultipleSelection(false)

        XCTAssertFalse(selection.allowsMultipleSelection)
        XCTAssertEqual(selection.assets, [second])
        XCTAssertEqual(selection.focusedAsset, second)
    }

    func testSetAllowsMultipleSelectionEnablesMultiSelect() {
        let configuration = InstagramPhotosPickerConfiguration(allowsMultipleSelection: false)
        let selection = InstagramPhotosSelection(configuration: configuration)
        let asset = makeAsset(id: "1")

        selection.focus(asset)
        selection.setAllowsMultipleSelection(true)

        XCTAssertTrue(selection.allowsMultipleSelection)
        XCTAssertEqual(selection.assets, [asset])
    }
}