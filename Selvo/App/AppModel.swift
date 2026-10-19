import Foundation
import Observation
import SwiftUI
import SelvoCore

/// Screens reachable from Home. Navigation is a single stack so Back always works.
enum Route: Hashable {
    case tiles(TileCategory)
    case suggest
    case show
    case listen
    case help
    case settings
}

/// App state: the profile, the message being composed, and navigation.
@Observable
final class AppModel {
    var profile: Profile?
    /// The text in the message strip.
    var message: String = ""
    /// The tile the message started from, if any.
    var selectedTile: TileItem?
    var path: [Route] = []
    /// True while the supporter setup flow is showing.
    var isInSetup = false

    let store: ProfileStore

    init(store: ProfileStore, profile: Profile?) {
        self.store = store
        self.profile = profile
    }

    /// Loads the saved profile. In the Simulator, or when launched with -SelvoDemoProfile YES,
    /// the demo profile for Lucas is seeded on first launch so the demo opens ready to use.
    static func launch(store: ProfileStore = .standard(), arguments: [String] = ProcessInfo.processInfo.arguments) -> AppModel {
        var profile = try? store.load()
        if profile == nil && shouldSeedDemo(arguments: arguments) {
            let lucas = DemoProfile.lucas
            try? store.save(lucas)
            profile = lucas
        }
        return AppModel(store: store, profile: profile)
    }

    static func shouldSeedDemo(arguments: [String]) -> Bool {
        if let i = arguments.firstIndex(of: "-SelvoDemoProfile"), i + 1 < arguments.count {
            return arguments[i + 1] == "YES"
        }
        #if targetEnvironment(simulator)
        return true
        #else
        return false
        #endif
    }

    /// An in-memory model with the demo profile, for previews and screenshot tests.
    static func preview(profile: Profile? = DemoProfile.lucas) -> AppModel {
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("selvo-preview-\(UUID().uuidString)/profile.json")
        return AppModel(store: ProfileStore(fileURL: url), profile: profile)
    }

    var theme: Theme {
        Theme(profile?.theme ?? .night, readingFont: profile?.readingFont ?? .lexend)
    }

    /// Changes the profile and saves it.
    func update(_ change: (inout Profile) -> Void) {
        guard var p = profile else { return }
        change(&p)
        profile = p
        try? store.save(p)
    }

    func open(_ route: Route) {
        path.append(route)
    }

    func goHome() {
        path.removeAll()
    }

    /// Speaks the message strip. Filled in on Day 3 with AVSpeechSynthesizer.
    func speak() {}

    func clearMessage() {
        message = ""
        selectedTile = nil
    }
}

extension TextSize {
    /// The smallest Dynamic Type size this setting allows. The phone's own larger setting wins.
    var minimumDynamicType: DynamicTypeSize {
        switch self {
        case .standard: return .large
        case .large: return .xxLarge
        case .larger: return .accessibility1
        }
    }
}
