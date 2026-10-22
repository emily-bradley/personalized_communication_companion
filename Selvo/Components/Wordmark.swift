import SwiftUI
import SelvoCore

/// The three sound bars: short, tall, short pills. Geometry from the handoff (viewBox 54x104).
struct SoundBars: Shape {
    func path(in rect: CGRect) -> Path {
        let sx = rect.width / 54, sy = rect.height / 104
        let bars: [(x: Double, y: Double, h: Double)] = [(4, 30, 44), (22, 6, 92), (40, 38, 28)]
        var path = Path()
        for bar in bars {
            let r = CGRect(x: rect.minX + bar.x * sx, y: rect.minY + bar.y * sy, width: 10 * sx, height: bar.h * sy)
            path.addRoundedRect(in: r, cornerSize: CGSize(width: 5 * sx, height: 5 * sx))
        }
        return path
    }
}

/// The wordmark drawn live: "Se", the sound bars as the "l", and "vo" in teal.
/// Stand in until the supplied logo artwork is added to the asset catalog.
struct Wordmark: View {
    @Environment(\.theme) private var theme
    var size: Double = 24

    var body: some View {
        HStack(alignment: .center, spacing: size * 0.06) {
            Text("Se").foregroundStyle(theme.colors.ink)
            SoundBars()
                .fill(theme.colors.ink)
                .frame(width: size * 0.5, height: size * 0.96)
            Text("vo").foregroundStyle(theme.colors.teal)
        }
        // Artwork: a fixed size that does not grow with Dynamic Type.
        .font(.custom(ReadingFont.lexend.postScriptName(semibold: true), fixedSize: size))
        .tracking(-0.02 * size)
        .lineLimit(1)
        .fixedSize()
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Selvo")
        .accessibilityAddTraits(.isImage)
    }
}

/// The orb: a teal disc with three white sound bars, lit from the upper left. The one glowing
/// object on a screen.
struct Orb: View {
    @Environment(\.theme) private var theme
    var diameter: Double = 160
    var glows: Bool = true

    var body: some View {
        ZStack {
            Circle().fill(theme.colors.orb)
            Circle().fill(
                RadialGradient(
                    colors: [theme.colors.orbGlow.opacity(0.9), theme.colors.orb.opacity(0)],
                    center: UnitPoint(x: 0.3, y: 0.25),
                    startRadius: 0,
                    endRadius: diameter * 0.6
                )
            )
            SoundBars()
                .fill(Color.white)
                .frame(width: diameter * 0.27, height: diameter * 0.52)
        }
        .frame(width: diameter, height: diameter)
        .modifier(OrbGlow(enabled: glows, token: theme.orbGlow))
        .accessibilityHidden(true)
    }
}

private struct OrbGlow: ViewModifier {
    let enabled: Bool
    let token: ShadowToken

    /// Drawn like the CSS halo in `glow-orb`: a disc grown by the spread, then blurred.
    /// A plain shadow has no spread, so it drew a smaller halo than the artboard.
    func body(content: Content) -> some View {
        if enabled {
            content.background(
                Circle()
                    .fill(Color(token.color))
                    .padding(-token.spread)
                    .blur(radius: token.blur / 2)
            )
        } else {
            content
        }
    }
}
