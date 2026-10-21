import SwiftUI
import SelvoCore

/// One suggested message with its attribution caption. Selected cards get tint, ring and a check.
struct SuggestionCard: View {
    @Environment(\.theme) private var theme
    let text: String
    let caption: String?
    var isSelected: Bool = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(alignment: .center, spacing: Spacing.space3) {
                VStack(alignment: .leading, spacing: Spacing.space1) {
                    Text(text)
                        .textStyle(TypeScale.body)
                        .foregroundStyle(theme.colors.ink)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                    if let caption {
                        Text(caption)
                            .textStyle(TypeScale.caption)
                            .foregroundStyle(theme.colors.teal)
                            // The attribution stops growing at xxxLarge so the message keeps
                            // the space and more of the three cards fit at the largest sizes.
                            .dynamicTypeSize(...DynamicTypeSize.xxxLarge)
                    }
                }
                Spacer(minLength: 0)
                if isSelected {
                    Image(systemName: "checkmark")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundStyle(theme.colors.primary)
                        .accessibilityHidden(true)
                }
            }
            .padding(.horizontal, Spacing.space4)
            // The artboard's 26pt message line and 20pt caption line include leading above the
            // first line and below the last, which lineSpacing leaves out.
            .padding(.vertical, Spacing.space4 + TypeScale.body.halfLeading + (caption == nil ? 0 : TypeScale.caption.halfLeading))
            .frame(maxWidth: .infinity, minHeight: Spacing.touchMin, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: Radius.md)
                    .fill(isSelected ? theme.colors.surfaceBrandTint : theme.colors.surfaceRaised)
            )
            .overlay(
                RoundedRectangle(cornerRadius: Radius.md)
                    .strokeBorder(theme.colors.hairline, lineWidth: isSelected ? 0 : 1)
            )
            .focusRing(isSelected, cornerRadius: Radius.md)
            .contentShape(RoundedRectangle(cornerRadius: Radius.md))
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}
