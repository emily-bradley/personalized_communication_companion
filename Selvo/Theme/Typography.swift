import SwiftUI
import SelvoCore

/// Maps each brand type style to the Dynamic Type style it scales with.
extension TypeStyle {
    var dynamicTypeStyle: Font.TextStyle {
        switch name {
        case "wordmark", "display": return .largeTitle
        case "lead", "heading": return .title2
        case "message": return .title
        case "caption": return .footnote
        case "primary-action": return .title3
        default: return .body
        }
    }

    /// Half of the leading that `lineSpacing` cannot add above the first line and below the
    /// last. Lexend's natural line height is about 1.25 times its size.
    var halfLeading: Double { max(0, lineHeight - size * 1.25) / 2 }
}

private struct TypeStyleModifier: ViewModifier {
    @Environment(\.theme) private var theme
    let style: TypeStyle

    func body(content: Content) -> some View {
        let font = Font.custom(
            theme.readingFont.postScriptName(semibold: style.isSemibold),
            size: style.size,
            relativeTo: style.dynamicTypeStyle
        )
        // Lexend's natural line height is about 1.25 times its size; add the rest as spacing.
        let extra = style.halfLeading * 2
        return content
            .font(font)
            .tracking(style.tracking * style.size)
            .lineSpacing(extra)
    }
}

extension View {
    /// Sets text in one of the brand styles, for example `.textStyle(TypeScale.body)`.
    func textStyle(_ style: TypeStyle) -> some View {
        modifier(TypeStyleModifier(style: style))
    }
}
