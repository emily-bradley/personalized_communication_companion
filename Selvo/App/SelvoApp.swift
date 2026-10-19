import SwiftUI
import SelvoCore

@main
struct SelvoApp: App {
    var body: some Scene {
        WindowGroup {
            RootView()
        }
    }
}

/// Day 1 root: the Nightlight ground with the wordmark. Screens replace this as they land.
struct RootView: View {
    var theme: Theme = .night

    var body: some View {
        ZStack {
            theme.colors.surface.ignoresSafeArea()
            VStack(spacing: Spacing.space6) {
                Orb(diameter: 160)
                Wordmark(size: 48)
            }
        }
        .environment(\.theme, theme)
        .preferredColorScheme(theme.colorScheme)
    }
}
