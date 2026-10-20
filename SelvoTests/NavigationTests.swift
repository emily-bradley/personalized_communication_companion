import XCTest
import SelvoCore
@testable import Selvo

/// A double tap on a tile or button must not push the same screen twice, or Back and Done
/// would seem to do nothing.
@MainActor
final class NavigationTests: XCTestCase {
    private func model() -> AppModel {
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("selvo-nav-\(UUID().uuidString)/profile.json")
        return AppModel.launch(store: ProfileStore(fileURL: url), arguments: ["Selvo", "-SelvoDemoProfile", "YES"])
    }

    func testOpeningTheSameScreenTwiceOpensItOnce() {
        let model = model()
        model.open(.suggest)
        model.open(.suggest)
        XCTAssertEqual(model.path, [.suggest])
    }

    func testDifferentScreensStillStack() {
        let model = model()
        model.open(.suggest)
        model.open(.show)
        model.open(.help)
        XCTAssertEqual(model.path, [.suggest, .show, .help])
    }
}
