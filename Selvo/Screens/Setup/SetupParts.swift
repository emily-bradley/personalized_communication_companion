import SwiftUI
import SelvoCore

/// Sizes used only by the setup steps.
enum SetupMetrics {
    /// Inputs and the dashed add row: 56pt, per the handoff.
    static let inputHeight: Double = 56
    /// The round symbol well in a list row.
    static let wellSide: Double = 48
    /// Choice pills such as the text sizes and speech rates.
    static let choiceHeight: Double = 48
    /// Bars on the theme swatches.
    static let swatchBarHeight: Double = 10
    /// Progress bar segments.
    static let progressHeight: Double = 4
}

/// Five segments under the top bar. Filled segments use primary, the rest hairline.
/// Hidden from VoiceOver because "Step N of 5" in the top bar says the same thing.
struct SetupProgressBar: View {
    @Environment(\.theme) private var theme
    let step: Int
    let total: Int

    var body: some View {
        HStack(spacing: Spacing.space2) {
            ForEach(1...total, id: \.self) { index in
                Capsule()
                    .fill(index <= step ? theme.colors.primary : theme.colors.hairline)
                    .frame(height: SetupMetrics.progressHeight)
            }
        }
        .accessibilityHidden(true)
    }
}

/// The question in message type with helper text under it.
struct SetupStepHeader: View {
    @Environment(\.theme) private var theme
    let title: String
    let helper: String

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.space2) {
            Text(title)
                .textStyle(TypeScale.message)
                .foregroundStyle(theme.colors.ink)
                .fixedSize(horizontal: false, vertical: true)
                .accessibilityAddTraits(.isHeader)
            Text(helper)
                .textStyle(TypeScale.body)
                .foregroundStyle(theme.colors.inkMuted)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

/// A small heading above a group of choices, such as "Text size".
struct SetupSectionLabel: View {
    @Environment(\.theme) private var theme
    let title: String

    var body: some View {
        Text(title)
            .textStyle(TypeScale.label)
            .foregroundStyle(theme.colors.ink)
            .accessibilityAddTraits(.isHeader)
    }
}

/// The 56pt pill text input with a border-strong edge.
struct SetupNameField: View {
    @Environment(\.theme) private var theme
    @Binding var text: String
    let submit: () -> Void

    var body: some View {
        TextField("", text: $text, prompt: Text("Name").foregroundColor(theme.colors.inkMuted))
            .textStyle(TypeScale.body)
            .foregroundStyle(theme.colors.ink)
            .textContentType(.name)
            .textInputAutocapitalization(.words)
            .autocorrectionDisabled()
            .submitLabel(.continue)
            .onSubmit(submit)
            .padding(.horizontal, Spacing.space6)
            .frame(maxWidth: .infinity, minHeight: SetupMetrics.inputHeight)
            .background(Capsule().fill(theme.colors.surface))
            .overlay(Capsule().strokeBorder(theme.colors.borderStrong, lineWidth: 1))
            .accessibilityLabel("Name")
    }
}

/// One person or place: a symbol on a round well, the name, and an optional note.
/// Rows added during setup show a text field for the name instead of fixed text.
struct SetupListRow: View {
    @Environment(\.theme) private var theme
    let symbol: String
    @Binding var label: String
    let note: String?
    var isEditable: Bool = false
    var fieldLabel: String = "Name"

    var body: some View {
        let children: AccessibilityChildBehavior = isEditable ? .contain : .combine
        HStack(spacing: Spacing.space3) {
            Image(systemName: symbol)
                .font(.system(size: 22, weight: .regular))
                .foregroundStyle(theme.colors.teal)
                .frame(width: SetupMetrics.wellSide, height: SetupMetrics.wellSide)
                .background(Circle().fill(theme.colors.surfaceSunken))
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 0) {
                if isEditable {
                    TextField("", text: $label, prompt: Text("Name").foregroundColor(theme.colors.inkMuted))
                        .textStyle(TypeScale.label)
                        .foregroundStyle(theme.colors.ink)
                        .textInputAutocapitalization(.words)
                        .autocorrectionDisabled()
                        .frame(minHeight: Spacing.touchMin)
                        .accessibilityLabel(fieldLabel)
                } else {
                    Text(label)
                        .textStyle(TypeScale.label)
                        .foregroundStyle(theme.colors.ink)
                        .fixedSize(horizontal: false, vertical: true)
                }
                if let note, !note.isEmpty {
                    Text(note)
                        .textStyle(TypeScale.caption)
                        .foregroundStyle(theme.colors.inkMuted)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            Spacer(minLength: 0)
        }
        // 10pt like the artboard rows: the 48pt well plus 10pt above and below.
        .padding(.vertical, 10)
        .padding(.horizontal, Spacing.space3)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(RoundedRectangle(cornerRadius: Radius.md).fill(theme.colors.surfaceRaised))
        .overlay(RoundedRectangle(cornerRadius: Radius.md).strokeBorder(theme.colors.hairline, lineWidth: 1))
        .accessibilityElement(children: children)
    }
}

/// The dashed "Add a person" row.
struct SetupAddRow: View {
    @Environment(\.theme) private var theme
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: Spacing.space2) {
                Image(systemName: "plus")
                    .font(.system(size: 20, weight: .semibold))
                    .accessibilityHidden(true)
                Text(title)
                    .textStyle(TypeScale.label)
            }
            .foregroundStyle(theme.colors.teal)
            .frame(maxWidth: .infinity, minHeight: SetupMetrics.inputHeight)
            .overlay(
                RoundedRectangle(cornerRadius: Radius.md)
                    .strokeBorder(theme.colors.borderStrong, style: StrokeStyle(lineWidth: 1, dash: [4, 4]))
            )
            .contentShape(RoundedRectangle(cornerRadius: Radius.md))
        }
        .buttonStyle(.plain)
        .accessibilityLabel(title)
    }
}

/// A pill in a row of choices. Selected: brand tint, 3pt focus ring and a check.
struct SetupChoicePill: View {
    @Environment(\.theme) private var theme
    let title: String
    var style: TypeStyle = TypeScale.label
    let accessibilityName: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .textStyle(style)
                .foregroundStyle(theme.colors.ink)
                .lineLimit(1)
                .minimumScaleFactor(0.6)
                .padding(.horizontal, Spacing.space6)
                .frame(maxWidth: .infinity, minHeight: SetupMetrics.choiceHeight)
                .background(Capsule().fill(isSelected ? theme.colors.surfaceBrandTint : Color.clear))
                .overlay(
                    Capsule().strokeBorder(
                        isSelected ? theme.colors.focus : theme.colors.borderStrong,
                        lineWidth: isSelected ? ComponentMetrics.focusRingWidth : 1
                    )
                )
                .overlay(alignment: .trailing) {
                    if isSelected {
                        Image(systemName: "checkmark")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(theme.colors.primary)
                            .padding(.trailing, Spacing.space3)
                            .accessibilityHidden(true)
                    }
                }
                .contentShape(Capsule())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(accessibilityName)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

/// A theme drawn in its own colors. Selected: 3pt focus ring and a check.
struct SetupThemeSwatch: View {
    @Environment(\.theme) private var theme
    let themeID: ThemeID
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        let swatch = Theme(themeID).colors
        Button(action: action) {
            VStack(alignment: .leading, spacing: Spacing.space2) {
                Capsule()
                    .fill(themeID == .night ? swatch.surfaceRaised : swatch.surfaceSunken)
                    .frame(height: SetupMetrics.swatchBarHeight)
                Capsule()
                    .fill(swatch.primary)
                    .frame(height: SetupMetrics.swatchBarHeight)
                    .padding(.trailing, Spacing.space12)
                HStack(spacing: Spacing.space1) {
                    // One word per label: never break it mid word. Both swatches stop growing at
                    // the same size so the two labels always match.
                    Text(themeID.displayName)
                        .textStyle(TypeScale.label)
                        .foregroundStyle(swatch.ink)
                        .lineLimit(1)
                        .minimumScaleFactor(0.6)
                        .dynamicTypeSize(...DynamicTypeSize.xxxLarge)
                    Spacer(minLength: 0)
                    if isSelected {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 20))
                            .symbolRenderingMode(.palette)
                            .foregroundStyle(swatch.onPrimary, swatch.primary)
                            .accessibilityHidden(true)
                    }
                }
            }
            .padding(Spacing.space3)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(RoundedRectangle(cornerRadius: Radius.md).fill(swatch.surface))
            .overlay(
                RoundedRectangle(cornerRadius: Radius.md)
                    .strokeBorder(theme.colors.borderStrong, lineWidth: isSelected ? 0 : 1)
            )
            .focusRing(isSelected, cornerRadius: Radius.md)
            .contentShape(RoundedRectangle(cornerRadius: Radius.md))
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(themeID.displayName) theme")
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

/// A sample message drawn with whatever theme and text size the environment carries.
struct SetupPreviewCard: View {
    @Environment(\.theme) private var theme
    let text: String

    var body: some View {
        Text(text)
            .textStyle(TypeScale.lead)
            .foregroundStyle(theme.colors.ink)
            .fixedSize(horizontal: false, vertical: true)
            .padding(Spacing.space4)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(RoundedRectangle(cornerRadius: Radius.md).fill(theme.colors.surfaceRaised))
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("Preview: \(text)")
    }
}
