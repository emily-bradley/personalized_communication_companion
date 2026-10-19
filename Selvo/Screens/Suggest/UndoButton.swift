import SwiftUI
import SelvoCore

/// Undo under the message strip. Always visible. With something to undo it shows the arrow in
/// teal; with nothing to undo the arrow is hidden and the word is ink-muted, so the off state
/// does not rely on color alone. The arrow keeps its space, so nothing moves.
/// Drawn like LinkButton, which has no disabled look of its own.
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
                    .opacity(isEnabled ? 1 : 0)
                    .accessibilityHidden(true)
                Text("Undo").textStyle(TypeScale.label)
            }
            .foregroundStyle(isEnabled ? theme.colors.teal : theme.colors.inkMuted)
            .frame(minHeight: ComponentMetrics.iconButtonSide)
            .contentShape(Rectangle())
        }
        // Not .plain: that style fades a disabled button to a low contrast grey.
        .buttonStyle(UndoButtonStyle())
        .disabled(!isEnabled)
        .accessibilityLabel("Undo")
        .accessibilityHint(isEnabled ? "Puts back what was there before your last change" : "Nothing to undo yet")
    }
}

/// Draws the label as given, so the disabled look is the full strength ink-muted color.
private struct UndoButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label.opacity(configuration.isPressed ? 0.7 : 1)
    }
}
