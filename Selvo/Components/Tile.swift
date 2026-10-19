import SwiftUI
import SelvoCore

/// Selection ring: 3pt in the focus color, 2pt outside the shape.
struct FocusRing: ViewModifier {
    @Environment(\.theme) private var theme
    let isOn: Bool
    let cornerRadius: Double

    func body(content: Content) -> some View {
        let outset = ComponentMetrics.focusRingOffset + ComponentMetrics.focusRingWidth / 2
        content.overlay {
            if isOn {
                RoundedRectangle(cornerRadius: cornerRadius + outset)
                    .stroke(theme.colors.focus, lineWidth: ComponentMetrics.focusRingWidth)
                    .padding(-outset)
            }
        }
    }
}

extension View {
    func focusRing(_ isOn: Bool, cornerRadius: Double) -> some View {
        modifier(FocusRing(isOn: isOn, cornerRadius: cornerRadius))
    }
}

/// What a tile shows above its label: a personal photo or an SF Symbol on a tinted well.
enum TileArtwork {
    case symbol(String)
    /// An artboard line drawing, stroked like the artboard icons (1.8 units in 24).
    case drawing(AnyShape)
    case image(Image)
}

/// A communication tile: picture plus a short label, at least 96pt, radius 16.
struct Tile: View {
    @Environment(\.theme) private var theme
    let label: String
    let artwork: TileArtwork
    var isSelected: Bool = false
    /// Fill behind a symbol; defaults to surface-sunken like the artboards.
    var wellColor: Color? = nil
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 0) {
                // The well gives up height first when space is short, but never below 44pt.
                artworkView
                    .frame(maxWidth: .infinity, minHeight: Spacing.touchMin, maxHeight: .infinity)
                    .background(wellColor ?? theme.colors.surfaceSunken)
                    .clipped()
                Text(label)
                    .textStyle(TypeScale.label)
                    .foregroundStyle(theme.colors.ink)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.85)
                    // The label always gets its full height, so text is never cut.
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.vertical, Spacing.space2)
                    .padding(.horizontal, 10)
                    .frame(maxWidth: .infinity)
                    .background(isSelected ? theme.colors.surfaceBrandTint : theme.colors.surfaceRaised)
            }
            .frame(minWidth: ComponentMetrics.tileMinSide, minHeight: ComponentMetrics.tileMinSide)
            .clipShape(RoundedRectangle(cornerRadius: Radius.md))
            .overlay(
                RoundedRectangle(cornerRadius: Radius.md)
                    .strokeBorder(theme.colors.hairline, lineWidth: isSelected ? 0 : 1)
            )
            .overlay(alignment: .topTrailing) {
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 24))
                        .symbolRenderingMode(.palette)
                        .foregroundStyle(theme.colors.onPrimary, theme.colors.primary)
                        .padding(6)
                        .accessibilityHidden(true)
                }
            }
            .focusRing(isSelected, cornerRadius: Radius.md)
            .contentShape(RoundedRectangle(cornerRadius: Radius.md))
        }
        .buttonStyle(TilePressStyle())
        .accessibilityLabel(label)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    @ViewBuilder private var artworkView: some View {
        switch artwork {
        case .symbol(let name):
            Image(systemName: name)
                .font(.system(size: 32, weight: .regular))
                .foregroundStyle(theme.colors.teal)
                .accessibilityHidden(true)
        case .drawing(let shape):
            shape
                .stroke(style: StrokeStyle(lineWidth: 32 * 1.8 / 24, lineCap: .round, lineJoin: .round))
                .foregroundStyle(theme.colors.teal)
                .frame(width: 32, height: 32)
                .accessibilityHidden(true)
        case .image(let image):
            image
                .resizable()
                .scaledToFill()
                .accessibilityHidden(true)
        }
    }
}

/// Pressed tiles dim slightly toward the sunken surface; no scale so nothing shifts.
private struct TilePressStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label.opacity(configuration.isPressed ? 0.8 : 1)
    }
}
