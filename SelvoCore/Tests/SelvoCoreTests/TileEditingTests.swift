import Foundation
import XCTest
@testable import SelvoCore

final class TileEditingTests: XCTestCase {
    private func profile() -> Profile {
        Profile(name: "Test", tiles: [
            TileItem(category: .photos, label: "A", symbol: "star", position: 0),
            TileItem(category: .photos, label: "B", symbol: "star", position: 1),
            TileItem(category: .photos, label: "C", symbol: "star", position: 3),
            TileItem(category: .places, label: "Home", symbol: "house", position: 0),
        ])
    }

    private func positions(_ profile: Profile) -> [UUID: Int] {
        var result: [UUID: Int] = [:]
        for tile in profile.tiles { result[tile.id] = tile.position }
        return result
    }

    func testHidingKeepsEveryPosition() {
        var p = profile()
        let before = positions(p)
        let b = p.tiles(in: .photos)[1]
        p.setHidden(true, tileID: b.id)
        XCTAssertEqual(positions(p), before)
        XCTAssertTrue(p.tiles.first(where: { $0.id == b.id })!.isHidden)
        let slots = TileLayout().slots(page: 0, tiles: p.tiles(in: .photos))
        XCTAssertEqual(slots[0]?.label, "A")
        XCTAssertNil(slots[1])
        XCTAssertEqual(slots[3]?.label, "C")
    }

    func testUnhidingRestoresTheSameSlot() {
        var p = profile()
        let b = p.tiles(in: .photos)[1]
        p.setHidden(true, tileID: b.id)
        p.setHidden(false, tileID: b.id)
        let slots = TileLayout().slots(page: 0, tiles: p.tiles(in: .photos))
        XCTAssertEqual(slots[1]?.label, "B")
        XCTAssertFalse(p.tiles.first(where: { $0.id == b.id })!.isHidden)
    }

    func testAddingUsesTheFirstFreeSlotAndMovesNothing() {
        var p = profile()
        let before = positions(p)
        let added = p.addTile(label: "New", symbol: "heart", category: .photos)
        XCTAssertEqual(added?.position, 2)
        XCTAssertEqual(added?.category, .photos)
        for (id, position) in before {
            XCTAssertEqual(p.tiles.first(where: { $0.id == id })?.position, position)
        }
        XCTAssertEqual(p.tiles(in: .photos).map(\.label), ["A", "B", "New", "C"])
    }

    func testAddingSkipsHiddenSlots() {
        var p = profile()
        p.setHidden(true, tileID: p.tiles(in: .places)[0].id)
        let added = p.addTile(label: "Work", symbol: "car", category: .places)
        XCTAssertEqual(added?.position, 1)
    }

    func testAddingTrimsAndIgnoresEmptyLabels() {
        var p = profile()
        XCTAssertNil(p.addTile(label: "   \n", symbol: "star", category: .photos))
        XCTAssertEqual(p.tiles.count, 4)
        let added = p.addTile(label: "  Tea  ", symbol: "cup.and.saucer", category: .photos)
        XCTAssertEqual(added?.label, "Tea")
    }

    func testRenameTrimsAndIgnoresEmptyLabels() {
        var p = profile()
        let a = p.tiles(in: .photos)[0]
        p.renameTile(a.id, to: "  Coffee ")
        XCTAssertEqual(p.tiles.first(where: { $0.id == a.id })?.label, "Coffee")
        p.renameTile(a.id, to: "   ")
        XCTAssertEqual(p.tiles.first(where: { $0.id == a.id })?.label, "Coffee")
        XCTAssertEqual(p.tiles.first(where: { $0.id == a.id })?.position, 0)
    }
}
