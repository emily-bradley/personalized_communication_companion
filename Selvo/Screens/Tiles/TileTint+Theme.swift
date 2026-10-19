import SwiftUI
import SelvoCore

extension ThemeColors {
    /// The well color behind a symbol tile.
    func well(for tint: TileTint) -> Color {
        switch tint {
        case .sunken: return surfaceSunken
        case .brand: return surfaceBrandTint
        case .indigo: return indigo
        }
    }
}
