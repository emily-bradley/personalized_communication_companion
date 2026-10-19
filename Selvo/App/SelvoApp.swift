import SwiftUI
import SelvoCore

@main
struct SelvoApp: App {
    @State private var model = AppModel.launch()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(model)
        }
    }
}

/// Welcome and setup until a profile exists, then Home with a navigation stack.
struct RootView: View {
    @Environment(AppModel.self) private var model
    @Environment(\.dynamicTypeSize) private var systemTypeSize

    var body: some View {
        @Bindable var model = model
        let theme = model.theme
        let minimum = model.profile?.textSize.minimumDynamicType ?? .large

        Group {
            if model.profile?.hasCompletedSetup == true {
                NavigationStack(path: $model.path) {
                    HomeView()
                        .navigationDestination(for: Route.self) { route in
                            destination(route)
                        }
                }
            } else if model.isInSetup {
                SetupView()
            } else {
                WelcomeView()
            }
        }
        .environment(\.theme, theme)
        .environment(\.dynamicTypeSize, max(systemTypeSize, minimum))
        .preferredColorScheme(theme.colorScheme)
        .tint(theme.colors.teal)
    }

    @ViewBuilder private func destination(_ route: Route) -> some View {
        switch route {
        case .tiles(let category): TileGridView(category: category)
        case .suggest: SuggestView()
        case .show: ShowView()
        case .listen: ListenView()
        case .help: HelpView()
        case .settings: SettingsView()
        }
    }
}
