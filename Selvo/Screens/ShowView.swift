import SwiftUI
import SelvoCore

/// Show (App-Show): the message large on surface-sunken, turned 180 degrees so the person
/// across the table can read it. The caption and Done stay the right way up for the holder.
struct ShowView: View {
    @Environment(AppModel.self) private var model
    @Environment(\.theme) private var theme

    /// The artboard sets the shown message at 44pt regular with a 1.2 line height. The brand
    /// scale has no 44pt style, so this is display (48pt) sized down to the artboard, in the
    /// regular weight like `message`. Named "display" so it scales with Large Title.
    private static let shownMessage = TypeStyle(
        name: TypeScale.display.name,
        size: 44,
        lineHeight: 52.8,
        weight: 400,
        tracking: 0
    )

    var body: some View {
        VStack(spacing: Spacing.space4) {
            Text(model.message)
                .textStyle(Self.shownMessage)
                .foregroundStyle(theme.colors.ink)
                .multilineTextAlignment(.center)
                .minimumScaleFactor(0.3)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .rotationEffect(.degrees(180))
                .accessibilityElement(children: .ignore)
                .accessibilityLabel(model.message)
                .accessibilityHint("Turned toward the listener")

            Text("Turned toward the listener. Tap Done when they have read it.")
                .textStyle(TypeScale.caption)
                .foregroundStyle(theme.colors.inkMuted)
                .multilineTextAlignment(.center)
                .lineLimit(3)
                .minimumScaleFactor(0.8)
                .frame(maxWidth: .infinity)
                .dynamicTypeSize(...DynamicTypeSize.accessibility1)

            PrimaryButton(title: "Done", accessibilityHint: "Goes back to your words") {
                if !model.path.isEmpty {
                    model.path.removeLast()
                }
            }
        }
        .padding(.horizontal, Spacing.space4)
        .padding(.top, Spacing.space2)
        .padding(.bottom, Spacing.space2)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(theme.colors.surfaceSunken.ignoresSafeArea())
        .toolbar(.hidden, for: .navigationBar)
    }
}
