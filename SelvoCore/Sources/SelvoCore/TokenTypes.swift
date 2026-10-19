import Foundation

/// An sRGB color with components from 0 to 1. Kept free of SwiftUI so SelvoCore builds anywhere.
public struct RGBA: Equatable, Sendable {
    public let red: Double
    public let green: Double
    public let blue: Double
    public let alpha: Double

    public init(hex: UInt32, alpha: Double = 1) {
        red = Double((hex >> 16) & 0xFF) / 255
        green = Double((hex >> 8) & 0xFF) / 255
        blue = Double(hex & 0xFF) / 255
        self.alpha = alpha
    }

    /// Relative luminance as defined by WCAG 2.
    public var luminance: Double {
        func channel(_ c: Double) -> Double {
            c <= 0.03928 ? c / 12.92 : pow((c + 0.055) / 1.055, 2.4)
        }
        return 0.2126 * channel(red) + 0.7152 * channel(green) + 0.0722 * channel(blue)
    }

    /// WCAG contrast ratio between two opaque colors, from 1 to 21.
    public func contrast(with other: RGBA) -> Double {
        let a = luminance, b = other.luminance
        return (max(a, b) + 0.05) / (min(a, b) + 0.05)
    }
}

public enum ThemeID: String, CaseIterable, Codable, Sendable {
    case night
    case day

    public var displayName: String {
        switch self {
        case .night: return "Nightlight"
        case .day: return "Daylight"
        }
    }

    public var palette: Palette {
        switch self {
        case .night: return .night
        case .day: return .day
        }
    }
}

/// One type style from the brand book. Sizes are points at the default Dynamic Type size.
public struct TypeStyle: Equatable, Sendable {
    public let name: String
    public let size: Double
    public let lineHeight: Double
    public let weight: Int
    /// Letter spacing in em.
    public let tracking: Double

    public init(name: String, size: Double, lineHeight: Double, weight: Int, tracking: Double) {
        self.name = name
        self.size = size
        self.lineHeight = lineHeight
        self.weight = weight
        self.tracking = tracking
    }

    public var isSemibold: Bool { weight >= 600 }
}

extension TypeScale {
    /// The label of the one primary action (Speak) and the Listen destination. The artboards
    /// set these at 20pt; every other label uses `label`.
    public static let primaryAction = TypeStyle(name: "primary-action", size: 20, lineHeight: 26, weight: 600, tracking: 0)
}

public struct ShadowToken: Equatable, Sendable {
    public let x: Double
    public let y: Double
    public let blur: Double
    public let spread: Double
    public let color: RGBA
}

/// The reading font the person chooses in Settings.
public enum ReadingFont: String, CaseIterable, Codable, Sendable {
    case lexend
    case atkinson

    public var displayName: String {
        switch self {
        case .lexend: return "Lexend"
        case .atkinson: return "Atkinson Hyperlegible"
        }
    }

    /// PostScript name of the bundled font file for a weight. Atkinson ships 400 and 700 only,
    /// so its labels use 700 as the nearest match to semibold.
    public func postScriptName(semibold: Bool) -> String {
        switch self {
        case .lexend: return semibold ? "Lexend-SemiBold" : "Lexend-Regular"
        case .atkinson: return semibold ? "AtkinsonHyperlegible-Bold" : "AtkinsonHyperlegible-Regular"
        }
    }
}

/// Sizes every control must respect. Views read these so tests can check the rules in one place.
public enum ComponentMetrics {
    public static let primaryButtonHeight = Spacing.touchPrimary
    public static let quietButtonHeight = Spacing.touchMin
    public static let topBarHeight = Spacing.touchMin
    public static let topBarSlotWidth: Double = 96
    public static let iconButtonSide = Spacing.touchMin
    public static let tileMinSide = Spacing.touchTile
    public static let tileImageMinHeight: Double = 72
    public static let messageStripMinHeight: Double = 72
    public static let focusRingWidth: Double = 3
    public static let focusRingOffset: Double = 2
    /// Clear must sit at least this far from Speak.
    public static let clearToSpeakMinDistance = Spacing.space12

    public static let allTappableHeights: [String: Double] = [
        "primaryButton": primaryButtonHeight,
        "quietButton": quietButtonHeight,
        "topBar": topBarHeight,
        "iconButton": iconButtonSide,
        "tile": tileMinSide,
    ]
}
