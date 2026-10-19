import SwiftUI
import SelvoCore

/// The first screen (App-Welcome): the orb, the wordmark, the tagline, and two ways in.
struct WelcomeView: View {
    @Environment(AppModel.self) private var model
    @Environment(\.theme) private var theme
    @Environment(\.dynamicTypeSize) private var typeSize

    var body: some View {
        Screen {
            VStack(spacing: Spacing.space4) {
                // Plain stack when it fits; scrolls only at very large text sizes.
                ScrollsWhenNeeded(alignment: .center) {
                    hero
                }
                .frame(maxHeight: .infinity)

                PrimaryButton(
                    title: "Set up together",
                    accessibilityHint: "Starts setup, one step at a time"
                ) {
                    model.isInSetup = true
                }

                Button(action: openExistingProfile) {
                    Text("I already have a profile")
                        .textStyle(TypeScale.label)
                        .foregroundStyle(theme.colors.teal)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity, minHeight: Spacing.touchMin)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel("I already have a profile")
                .accessibilityHint("Opens Selvo with your saved profile")
            }
            // The artboard uses 24pt side margins here: the Screen's 16 plus 8.
            .padding(.horizontal, Spacing.space2)
        }
        .toolbar(.hidden, for: .navigationBar)
    }

    private var hero: some View {
        let compact = typeSize.isAccessibilitySize
        return VStack(spacing: compact ? Spacing.space6 : Spacing.space8) {
            Orb(diameter: compact ? 120 : 180)
            Wordmark(size: 56)
            Text("Your voice. Your way.")
                .textStyle(TypeScale.message)
                .foregroundStyle(theme.colors.ink)
                .fixedSize(horizontal: false, vertical: true)
            Text("Set up Selvo together, with the person who will use it holding the phone.")
                .textStyle(TypeScale.body)
                .foregroundStyle(theme.colors.inkMuted)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: 300)
        }
        .multilineTextAlignment(.center)
        .frame(maxWidth: .infinity)
    }

    /// For the demo, the existing profile is Lucas.
    private func openExistingProfile() {
        let lucas = DemoProfile.lucas
        try? model.store.save(lucas)
        model.profile = lucas
    }
}
