import SwiftUI
import SelvoCore

/// The active look: color tokens for Nightlight or Daylight plus the chosen reading font.
struct Theme {
    let id: ThemeID
    let colors: ThemeColors
    let readingFont: ReadingFont

    init(_ id: ThemeID, readingFont: ReadingFont = .lexend) {
        self.id = id
        self.colors = ThemeColors(id.palette)
        self.readingFont = readingFont
    }

    static let night = Theme(.night)
    static let day = Theme(.day)

    var colorScheme: ColorScheme { id == .night ? .dark : .light }

    var sheetShadow: ShadowToken { id == .night ? Shadows.shadowSheetNight : Shadows.shadowSheetDay }
    var orbGlow: ShadowToken { id == .night ? Shadows.glowOrbNight : Shadows.glowOrbDay }
}

extension Color {
    init(_ rgba: RGBA) {
        self.init(.sRGB, red: rgba.red, green: rgba.green, blue: rgba.blue, opacity: rgba.alpha)
    }
}

private struct ThemeKey: EnvironmentKey {
    static let defaultValue = Theme.night
}

extension EnvironmentValues {
    var theme: Theme {
        get { self[ThemeKey.self] }
        set { self[ThemeKey.self] = newValue }
    }
}

extension View {
    /// Applies a token shadow. SwiftUI has no spread, so spread is folded into the radius.
    func tokenShadow(_ token: ShadowToken) -> some View {
        shadow(color: Color(token.color), radius: (token.blur + token.spread) / 2, x: token.x, y: token.y)
    }
}
