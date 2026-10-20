import Foundation
import XCTest
@testable import SelvoCore

final class TileLayoutTests: XCTestCase {
    private func tile(_ label: String, _ position: Int, hidden: Bool = false) -> TileItem {
        TileItem(category: .photos, label: label, symbol: "star", position: position, isHidden: hidden)
    }

    func testSlotsKeepTheirPositionsWhenATileIsHidden() {
        let layout = TileLayout()
        let tiles = [tile("A", 0), tile("B", 1, hidden: true), tile("C", 2)]
        let slots = layout.slots(page: 0, tiles: tiles)
        XCTAssertEqual(slots.count, 9)
        XCTAssertEqual(slots[0]?.label, "A")
        XCTAssertNil(slots[1])
        XCTAssertEqual(slots[2]?.label, "C")
    }

    func testPagingByFixedSlots() {
        let layout = TileLayout()
        let tiles = (0..<12).map { tile("T\($0)", $0) }
        XCTAssertEqual(layout.pageCount(for: tiles), 2)
        let page2 = layout.slots(page: 1, tiles: tiles)
        XCTAssertEqual(page2[0]?.label, "T9")
        XCTAssertEqual(page2[2]?.label, "T11")
        XCTAssertNil(page2[3])
    }

    func testEmptyGridHasOnePage() {
        XCTAssertEqual(TileLayout().pageCount(for: []), 1)
    }

    func testNextFreePositionSkipsHiddenSlots() {
        let layout = TileLayout()
        let tiles = [tile("A", 0), tile("B", 1, hidden: true), tile("C", 3)]
        XCTAssertEqual(layout.nextFreePosition(in: tiles), 2)
    }

    func testAddingATileNeverMovesExistingTiles() {
        let layout = TileLayout()
        var tiles = [tile("A", 0), tile("C", 2)]
        let before = layout.slots(page: 0, tiles: tiles)
        tiles.append(tile("New", layout.nextFreePosition(in: tiles)))
        let after = layout.slots(page: 0, tiles: tiles)
        XCTAssertEqual(after[0], before[0])
        XCTAssertEqual(after[2], before[2])
        XCTAssertEqual(after[1]?.label, "New")
    }
}

final class ProfileStoreTests: XCTestCase {
    private var store: ProfileStore!
    private var dir: URL!

    override func setUpWithError() throws {
        dir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        store = ProfileStore(fileURL: dir.appendingPathComponent("profile.json"))
    }

    override func tearDownWithError() throws {
        try? FileManager.default.removeItem(at: dir)
    }

    func testLoadReturnsNilBeforeAnythingIsSaved() throws {
        XCTAssertNil(try store.load())
    }

    func testRoundTrip() throws {
        var profile = DemoProfile.lucas
        profile.theme = .day
        try store.save(profile)
        XCTAssertEqual(try store.load(), profile)
    }

    func testSavePhotoWritesAFile() throws {
        let name = try store.savePhoto(Data([1, 2, 3]))
        XCTAssertEqual(try Data(contentsOf: store.photoURL(named: name)), Data([1, 2, 3]))
    }
}

final class DemoProfileTests: XCTestCase {
    func testLucasHasEveryCategory() {
        let lucas = DemoProfile.lucas
        XCTAssertEqual(lucas.name, "Lucas")
        for category in TileCategory.allCases {
            XCTAssertFalse(lucas.tiles(in: category).isEmpty, category.title)
        }
    }

    func testDemoTilesUseSymbolsNotPhotos() {
        XCTAssertTrue(DemoProfile.lucas.tiles.allSatisfy { $0.photoFileName == nil && !$0.symbol.isEmpty })
    }

    func testPositionsAreUniquePerCategory() {
        for category in TileCategory.allCases {
            let positions = DemoProfile.lucas.tiles(in: category).map(\.position)
            XCTAssertEqual(Set(positions).count, positions.count, category.title)
        }
    }

    func testPhotosNeedsTwoPages() {
        XCTAssertEqual(TileLayout().pageCount(for: DemoProfile.lucas.tiles(in: .photos)), 2)
    }

    func testGreeting() {
        XCTAssertEqual(Greeting.text(name: "Lucas", hour: 19), "Good evening, Lucas. Where would you like to start?")
        XCTAssertTrue(Greeting.text(name: "Lucas", hour: 8).hasPrefix("Good morning"))
        XCTAssertTrue(Greeting.text(name: "Lucas", hour: 13).hasPrefix("Good afternoon"))
    }

    func testSetupThemeStaysWhenTheThemeChanges() throws {
        var profile = Profile(name: "Maya", theme: .night)
        XCTAssertEqual(profile.setupTheme, .night)
        profile.theme = .day
        XCTAssertEqual(profile.setupTheme, .night)

        // Profiles saved before the setup theme was recorded still load.
        var json = try JSONSerialization.jsonObject(with: JSONEncoder().encode(profile)) as! [String: Any]
        json.removeValue(forKey: "setupTheme")
        let old = try JSONDecoder().decode(Profile.self, from: JSONSerialization.data(withJSONObject: json))
        XCTAssertNil(old.setupTheme)
        XCTAssertEqual(old.theme, .day)
    }
}
