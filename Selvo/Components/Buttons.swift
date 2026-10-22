import SwiftUI
import SelvoCore

/// The one primary action on a screen, such as Speak: 64pt tall, full width, pill.
struct PrimaryButton: View {
    @Environment(\.theme) private var theme
    let title: String
    var isEnabled: Bool = true
    var accessibilityHint: String? = nil
    /// The sound bars before the label: the brand book's Speak glyph, so Speak reads without words.
    var showsSoundBars: Bool = false
    let action: () -> Void
    // The glyph is as tall as a capital letter in the 20pt label, and grows with it.
    @ScaledMetric(relativeTo: .title3) private var barsHeight: Double = 20

    var body: some View {
        Button(action: action) {
            HStack(spacing: Spacing.space3) {
                if showsSoundBars {
                    SoundBars()
                        .fill(.foreground)
                        .frame(width: barsHeight * 54 / 104, height: barsHeight)
                        .accessibilityHidden(true)
                }
                Text(title)
                    .textStyle(TypeScale.primaryAction)
                    .multilineTextAlignment(.center)
            }
                // Keeps long labels clear of the pill's ends at the largest text sizes.
                .padding(.horizontal, Spacing.space4)
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
            // The shadow belongs to the capsule only, so the label text stays crisp.
            .background(Capsule().fill(fill).tokenShadow(theme.sheetShadow))
            .contentShape(Capsule())
    }
}

/// A secondary action such as Another, Incorrect, Clear or Cancel: 44pt outlined pill.
struct QuietButton: View {
    @Environment(\.theme) private var theme
    let title: String
    var fillsWidth: Bool = false
    var height: Double = ComponentMetrics.quietButtonHeight
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .textStyle(TypeScale.label)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
                .padding(.horizontal, Spacing.space4)
                .frame(maxWidth: fillsWidth ? .infinity : nil, minHeight: height)
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

/// A text link styled action in teal with an icon, such as Show and Undo.
struct LinkButton<Icon: View>: View {
    @Environment(\.theme) private var theme
    let title: String
    let icon: Icon
    let action: () -> Void

    init(title: String, action: @escaping () -> Void, @ViewBuilder icon: () -> Icon) {
        self.title = title
        self.action = action
        self.icon = icon()
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                icon
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

extension LinkButton where Icon == Image {
    init(title: String, systemImage: String, action: @escaping () -> Void) {
        self.init(title: title, action: action) { Image(systemName: systemImage) }
    }
}

/// The Show icon from the artboard: a card frame with three lines of text, drawn in a 24 unit
/// box with a 2 unit stroke. 22pt at the default text size, growing with the label.
struct ShowGlyph: View {
    @ScaledMetric(relativeTo: .body) private var side: Double = 22

    var body: some View {
        ShowGlyphShape()
            .stroke(style: StrokeStyle(lineWidth: side / 12, lineCap: .round, lineJoin: .round))
            .frame(width: side, height: side)
    }
}

private struct ShowGlyphShape: Shape {
    func path(in rect: CGRect) -> Path {
        let unit = rect.width / 24
        func point(_ x: Double, _ y: Double) -> CGPoint {
            CGPoint(x: rect.minX + x * unit, y: rect.minY + y * unit)
        }
        var path = Path()
        path.addRoundedRect(
            in: CGRect(origin: point(3, 4), size: CGSize(width: 18 * unit, height: 16 * unit)),
            cornerSize: CGSize(width: 3 * unit, height: 3 * unit)
        )
        for (y, length) in [(9.0, 6.0), (12.0, 10.0), (15.0, 8.0)] {
            path.move(to: point(7, y))
            path.addLine(to: point(7 + length, y))
        }
        return path
    }
}

/// Back, always top left.
struct BackButton: View {
    @Environment(\.theme) private var theme
    /// 20pt at the default text size, growing with the label so it does not look thin beside
    /// it at larger sizes. The top bar caps both at xxxLarge.
    @ScaledMetric(relativeTo: .body) private var chevronSize: Double = 20
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 2) {
                Image(systemName: "chevron.left")
                    .font(.system(size: chevronSize, weight: .semibold))
                    .accessibilityHidden(true)
                Text("Back").textStyle(TypeScale.label).lineLimit(1).fixedSize()
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
                .lineLimit(1)
                .fixedSize()
                .foregroundStyle(theme.colors.danger)
                .padding(.horizontal, Spacing.space3)
                .frame(minWidth: ComponentMetrics.iconButtonSide, minHeight: ComponentMetrics.iconButtonSide)
                .overlay(Capsule().strokeBorder(theme.colors.danger, lineWidth: 1))
                .contentShape(Capsule())
        }
        .buttonStyle(.plain)
        // The pill stops growing at the first accessibility size so it stays one line.
        .dynamicTypeSize(...DynamicTypeSize.accessibility1)
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
