import SwiftUI
import SelvoCore

/// Undo under the message strip. Always visible; teal when there is something to undo and
/// ink-muted when there is not. Drawn like LinkButton, which has no disabled look of its own.
struct UndoButton: View {
    @Environment(\.theme) private var theme
    let isEnabled: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            // 6pt gap matches LinkButton and the artboard.
            HStack(spacing: 6) {
                Image(systemName: "arrow.uturn.backward")
                    .imageScale(.large)
                    .accessibilityHidden(true)
                Text("Undo").textStyle(TypeScale.label)
            }
            .foregroundStyle(isEnabled ? theme.colors.teal : theme.colors.inkMuted)
            .frame(minHeight: ComponentMetrics.iconButtonSide)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .disabled(!isEnabled)
        .accessibilityLabel("Undo")
        .accessibilityHint(isEnabled ? "Puts back what was there before your last change" : "Nothing to undo yet")
    }
}
