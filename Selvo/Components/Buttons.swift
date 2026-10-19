import SwiftUI
import SelvoCore

/// The one primary action on a screen, such as Speak: 64pt tall, full width, pill.
struct PrimaryButton: View {
    @Environment(\.theme) private var theme
    let title: String
    var isEnabled: Bool = true
    var accessibilityHint: String? = nil
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .textStyle(TypeScale.primaryAction)
                .frame(maxWidth: .infinity, minHeight: ComponentMetrics.primaryButtonHeight)
        }
        .buttonStyle(PrimaryButtonStyle(theme: theme, isEnabled: isEnabled))
        .disabled(!isEnabled)
        .accessibilityHint(accessibilityHint ?? "")
    }
}

struct PrimaryButtonStyle: ButtonStyle {
    let theme: Theme
    let isEnabled: Bool

    func makeBody(configuration: Configuration) -> some View {
        let c = theme.colors
        let fill = !isEnabled ? c.surfaceSunken : (configuration.isPressed ? c.primaryPressed : c.primary)
        return configuration.label
            .foregroundStyle(isEnabled ? c.onPrimary : c.inkMuted)
            .background(Capsule().fill(fill))
            .contentShape(Capsule())
            .tokenShadow(theme.sheetShadow)
    }
}

/// A secondary action such as Another, Incorrect, Clear or Cancel: 44pt outlined pill.
struct QuietButton: View {
    @Environment(\.theme) private var theme
    let title: String
    var fillsWidth: Bool = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .textStyle(TypeScale.label)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
                .padding(.horizontal, Spacing.space4)
                .frame(maxWidth: fillsWidth ? .infinity : nil, minHeight: ComponentMetrics.quietButtonHeight)
        }
        .buttonStyle(QuietButtonStyle(theme: theme))
    }
}

struct QuietButtonStyle: ButtonStyle {
    let theme: Theme

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(theme.colors.ink)
            .background(Capsule().fill(configuration.isPressed ? theme.colors.surfaceSunken : Color.clear))
            .overlay(Capsule().strokeBorder(theme.colors.borderStrong, lineWidth: 1))
            .contentShape(Capsule())
    }
}

/// A text link styled action in teal with an SF Symbol, such as Show and Undo.
struct LinkButton: View {
    @Environment(\.theme) private var theme
    let title: String
    let systemImage: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: systemImage)
                    .imageScale(.large)
                    .accessibilityHidden(true)
                Text(title).textStyle(TypeScale.label)
            }
            .foregroundStyle(theme.colors.teal)
            .frame(minHeight: ComponentMetrics.iconButtonSide)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

/// Back, always top left.
struct BackButton: View {
    @Environment(\.theme) private var theme
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 2) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 20, weight: .semibold))
                    .accessibilityHidden(true)
                Text("Back").textStyle(TypeScale.label)
            }
            .foregroundStyle(theme.colors.teal)
            .padding(.trailing, Spacing.space2)
            .frame(minHeight: ComponentMetrics.iconButtonSide)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Back")
    }
}

/// Help, always top right: a danger outlined pill.
struct HelpButton: View {
    @Environment(\.theme) private var theme
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text("Help")
                .textStyle(TypeScale.label)
                .foregroundStyle(theme.colors.danger)
                .padding(.horizontal, Spacing.space3)
                .frame(minWidth: ComponentMetrics.iconButtonSide, minHeight: ComponentMetrics.iconButtonSide)
                .overlay(Capsule().strokeBorder(theme.colors.danger, lineWidth: 1))
                .contentShape(Capsule())
        }
        .buttonStyle(.plain)
        .accessibilityHint("Shows your help message")
    }
}

/// A 44pt round icon button such as the Settings gear.
struct IconButton: View {
    @Environment(\.theme) private var theme
    let systemImage: String
    let label: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .font(.system(size: 24, weight: .regular))
                .foregroundStyle(theme.colors.teal)
                .frame(width: ComponentMetrics.iconButtonSide, height: ComponentMetrics.iconButtonSide)
                .contentShape(Circle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(label)
    }
}
