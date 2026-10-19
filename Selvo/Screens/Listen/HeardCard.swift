import SwiftUI
import SelvoCore

/// What was just heard, on a raised card with who said it as a caption.
struct HeardCard: View {
    @Environment(\.theme) private var theme
    let speaker: String
    let text: String

    static let placeholder = "When someone talks to you, their words show here."

    var body: some View {
        let isEmpty = text.isEmpty
        VStack(alignment: .leading, spacing: Spacing.space1) {
            Text(speaker)
                .textStyle(TypeScale.caption)
                .foregroundStyle(theme.colors.inkMuted)
            Text(isEmpty ? Self.placeholder : text)
                .textStyle(TypeScale.lead)
                .foregroundStyle(isEmpty ? theme.colors.inkMuted : theme.colors.ink)
                .multilineTextAlignment(.leading)
                // Long speech keeps its latest words in view.
                .lineLimit(6)
                .truncationMode(.head)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, Spacing.space4)
        .padding(.horizontal, Spacing.space4 + Spacing.space1)
        .background(RoundedRectangle(cornerRadius: Radius.lg).fill(theme.colors.surfaceRaised))
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(isEmpty ? Self.placeholder : "\(speaker): \(text)")
        .accessibilityAddTraits(.updatesFrequently)
    }
}

/// The constant, visible sign of whether the phone is listening, or why it is not.
struct ListeningStatus: View {
    @Environment(\.theme) private var theme
    let status: SpeechListener.Status
    let onOpenSettings: () -> Void

    static let unavailableMessage = "Listening is not available on this phone right now."

    var body: some View {
        switch status {
        case .listening:
            line("Listening", color: theme.colors.teal)
        case .starting:
            line("Getting ready to listen", color: theme.colors.inkMuted)
        case .idle:
            line("Not listening", color: theme.colors.inkMuted)
        case .denied(let message):
            VStack(spacing: Spacing.space3) {
                explanation(message)
                QuietButton(title: "Open Settings", action: onOpenSettings)
                    .accessibilityHint("Opens Selvo in the Settings app")
                    .dynamicTypeSize(...DynamicTypeSize.xxxLarge)
            }
        case .unavailable:
            explanation(Self.unavailableMessage)
        }
    }

    private func line(_ title: String, color: Color) -> some View {
        Text(title)
            .textStyle(TypeScale.label)
            .foregroundStyle(color)
            .multilineTextAlignment(.center)
            .frame(minHeight: Spacing.touchMin)
            .accessibilityLabel(title)
    }

    private func explanation(_ message: String) -> some View {
        Text(message)
            .textStyle(TypeScale.body)
            .foregroundStyle(theme.colors.ink)
            .multilineTextAlignment(.center)
            .fixedSize(horizontal: false, vertical: true)
    }
}
