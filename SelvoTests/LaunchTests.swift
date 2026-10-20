import XCTest
import SelvoCore
@testable import Selvo

/// The launch arguments `scripts/demo.sh` passes: plain, `--fresh` and `--welcome`.
@MainActor
final class LaunchTests: XCTestCase {
    private func storeWithRehearsalChanges() throws -> ProfileStore {
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("selvo-launch-\(UUID().uuidString)/profile.json")
        let store = ProfileStore(fileURL: url)
        var changed = DemoProfile.lucas
        changed.name = "Maya"
        changed.theme = .day
        try store.save(changed)
        return store
    }

    func testPlainLaunchKeepsTheSavedProfile() throws {
        let store = try storeWithRehearsalChanges()
        let model = AppModel.launch(store: store, arguments: ["Selvo", "-SelvoDemoProfile", "YES"])
        XCTAssertEqual(model.profile?.name, "Maya")
        XCTAssertEqual(model.profile?.theme, .day)
    }

    func testFreshLaunchStartsOverWithLucas() throws {
        let store = try storeWithRehearsalChanges()
        let model = AppModel.launch(store: store, arguments: ["Selvo", "-SelvoDemoProfile", "YES", "-SelvoResetProfile"])
        XCTAssertEqual(model.profile, DemoProfile.lucas)
        XCTAssertEqual(try store.load(), DemoProfile.lucas)
    }

    func testWelcomeLaunchStartsWithNoProfile() throws {
        let store = try storeWithRehearsalChanges()
        let model = AppModel.launch(store: store, arguments: ["Selvo", "-SelvoDemoProfile", "NO", "-SelvoResetProfile"])
        XCTAssertNil(model.profile)
    }
}
