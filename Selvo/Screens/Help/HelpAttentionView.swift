import SwiftUI
import UIKit
import SelvoCore

/// The attention screen: the full danger ground with the person's help title and phrase in
/// on-primary type, and Done as an outlined pill at the bottom. It never times out, and the
/// phone stays awake while it shows.
struct HelpAttentionView: View {
    @Environment(\.theme) private var theme
    let title: String
    let phrase: String
    let done: () -> Void

    /// The artboard sets the title at 44pt semibold with a 1.2 line height. The brand scale has
    /// no 44pt style, so this is display (48pt) sized down to the artboard. Named "display" so
    /// it scales with Large Title.
    private static let titleStyle = TypeStyle(
        name: TypeScale.display.name,
        size: 44,
        lineHeight: 52.8,
        weight: 600,
        tracking: 0
    )

    /// The artboard sets the phrase at 30pt regular with a 40pt line height, which is exactly
    /// the brand `message` style.
    private static let phraseStyle = TypeScale.message

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.space6) {
            VStack(alignment: .leading, spacing: Spacing.space6) {
                Spacer(minLength: 0)
                Text(title)
                    .textStyle(Self.titleStyle)
                    .minimumScaleFactor(0.4)
                    .accessibilityAddTraits(.isHeader)
                if !phrase.isEmpty {
                    Text(phrase)
                        .textStyle(Self.phraseStyle)
                        .minimumScaleFactor(0.4)
                }
                Spacer(minLength: 0)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
            .layoutPriority(1)
            .dynamicTypeSize(...DynamicTypeSize.accessibility2)

            Button(action: done) {
                Text("Done")
                    .textStyle(TypeScale.primaryAction)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                    .frame(maxWidth: .infinity, minHeight: ComponentMetrics.primaryButtonHeight)
            }
            .buttonStyle(HelpOutlinedButtonStyle(theme: theme))
            .accessibilityHint("Closes the help screen")
        }
        .foregroundStyle(theme.colors.onPrimary)
        .padding(.horizontal, Spacing.space6)
        .padding(.top, Spacing.space2)
        .padding(.bottom, Spacing.space2)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(theme.colors.danger.ignoresSafeArea())
        .onAppear { UIApplication.shared.isIdleTimerDisabled = true }
        .onDisappear { UIApplication.shared.isIdleTimerDisabled = false }
    }
}

/// "Yes, show it": a 64pt pill filled with danger and an on-primary label. Used only on Help.
struct HelpFilledButtonStyle: ButtonStyle {
    let theme: Theme

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(theme.colors.onPrimary)
            .background(Capsule().fill(theme.colors.danger))
            .opacity(configuration.isPressed ? 0.85 : 1)
            .contentShape(Capsule())
    }
}

/// Done on the attention screen: a 64pt pill outlined 2pt in on-primary on the danger ground.
struct HelpOutlinedButtonStyle: ButtonStyle {
    let theme: Theme

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(theme.colors.onPrimary)
            .background(Capsule().fill(configuration.isPressed ? theme.colors.onPrimary.opacity(0.12) : Color.clear))
            .overlay(Capsule().strokeBorder(theme.colors.onPrimary, lineWidth: 2))
            .contentShape(Capsule())
    }
}
