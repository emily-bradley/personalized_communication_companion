import SwiftUI
import SelvoCore

/// Home (App-Home): the message strip, a greeting, the five destinations and Speak.
struct HomeView: View {
    @Environment(AppModel.self) private var model
    @Environment(\.theme) private var theme

    var body: some View {
        Screen {
            TopBar(title: "") {
                Wordmark()
            } trailing: {
                HStack(spacing: 0) {
                    IconButton(systemImage: "gearshape", label: "Settings") { model.open(.settings) }
                    HelpButton { model.open(.help) }
                }
            }

            MessageStrip(message: model.message, placeholder: "Tap a picture to start.")

            if let name = model.profile?.name {
                Text(Greeting.text(name: name, hour: Calendar.current.component(.hour, from: Date())))
                    .textStyle(TypeScale.caption)
                    .foregroundStyle(theme.colors.inkMuted)
                    .lineLimit(2)
                    .minimumScaleFactor(0.7)
                    .padding(.horizontal, Spacing.space1)
            }

            VStack(spacing: Spacing.space3) {
                HStack(spacing: Spacing.space3) {
                    destination(.photos)
                    destination(.places)
                }
                HStack(spacing: Spacing.space3) {
                    destination(.people)
                    destination(.phrases)
                }
                ListenRow { model.open(.listen) }
            }
            .frame(maxHeight: .infinity)

            PrimaryButton(title: "Speak", isEnabled: !model.message.isEmpty) {
                model.speak()
            }
        }
        .toolbar(.hidden, for: .navigationBar)
    }

    private func destination(_ category: TileCategory) -> some View {
        Tile(label: category.title, artwork: .symbol(category.symbol)) {
            model.open(.tiles(category))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .dynamicTypeSize(...DynamicTypeSize.accessibility1)
        .accessibilityHint("Opens \(category.title)")
    }
}

/// The fifth destination: a full width row with the microphone and "Listen".
private struct ListenRow: View {
    @Environment(\.theme) private var theme
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: Spacing.space3) {
                Image(systemName: "mic")
                    .font(.system(size: 28, weight: .regular))
                    .foregroundStyle(theme.colors.teal)
                    .accessibilityHidden(true)
                Text("Listen")
                    .textStyle(TypeScale.primaryAction)
                    .foregroundStyle(theme.colors.ink)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            .frame(maxWidth: .infinity, minHeight: ComponentMetrics.tileImageMinHeight, maxHeight: .infinity)
            .background(RoundedRectangle(cornerRadius: Radius.md).fill(theme.colors.surfaceRaised))
            .overlay(RoundedRectangle(cornerRadius: Radius.md).strokeBorder(theme.colors.hairline, lineWidth: 1))
            .contentShape(RoundedRectangle(cornerRadius: Radius.md))
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Listen")
        .accessibilityHint("Shows what people say to you as text")
    }
}
