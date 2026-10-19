import SwiftUI
import SelvoCore

/// Every core component on one screen, used by the screenshot test to check them in both themes.
struct ComponentGallery: View {
    var body: some View {
        Screen {
            TopBar(title: "Coffee") {
                BackButton {}
            } trailing: {
                HelpButton {}
            }
            MessageStrip(message: nil)
            MessageStrip(message: "Coffee first. Then I'll be nice.")
            HStack {
                LinkButton(title: "Show", systemImage: "text.alignleft") {}
                Spacer()
                LinkButton(title: "Undo", systemImage: "arrow.uturn.backward") {}
            }
            HStack(spacing: Spacing.space3) {
                Tile(label: "Coffee", artwork: .symbol("cup.and.saucer"), isSelected: true) {}
                Tile(label: "Park", artwork: .symbol("tree")) {}
                Tile(label: "Home", artwork: .symbol("house")) {}
            }
            .frame(height: 120)
            SuggestionCard(text: "Can we get coffee before work?", caption: "Suggested for Lucas · plain", isSelected: true) {}
            SuggestionCard(text: "Is there time for coffee?", caption: "Suggested for Lucas · short") {}
            HStack(spacing: Spacing.space3) {
                QuietButton(title: "Another", fillsWidth: true) {}
                QuietButton(title: "Incorrect", fillsWidth: true) {}
            }
            Spacer(minLength: 0)
            PrimaryButton(title: "Speak", isEnabled: false) {}
            PrimaryButton(title: "Speak") {}
        }
    }
}
