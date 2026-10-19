import SwiftUI
import SelvoCore

/// The message being composed, in large regular type on a raised strip.
struct MessageStrip: View {
    @Environment(\.theme) private var theme
    let message: String?
    var placeholder: String = "Tap a picture to start."

    var body: some View {
        let isEmpty = (message ?? "").isEmpty
        Text(isEmpty ? placeholder : message!)
            .textStyle(TypeScale.message)
            .lineLimit(3)
            .minimumScaleFactor(0.6)
            .foregroundStyle(isEmpty ? theme.colors.inkMuted : theme.colors.ink)
            .frame(maxWidth: .infinity, minHeight: ComponentMetrics.messageStripMinHeight - 32, alignment: .leading)
            .padding(.vertical, Spacing.space4)
            .padding(.horizontal, 20)
            .background(RoundedRectangle(cornerRadius: Radius.lg).fill(theme.colors.surfaceRaised))
            .accessibilityElement(children: .combine)
            .accessibilityLabel(isEmpty ? "Message is empty. \(placeholder)" : "Message: \(message!)")
            .accessibilityAddTraits(.updatesFrequently)
    }
}
