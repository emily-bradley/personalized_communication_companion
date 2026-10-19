import SwiftUI
import SelvoCore

/// The speech rate track from App-Settings, drawn with shapes so it renders in screenshots.
/// Five steps from slowest to fastest; tap or drag to a step. VoiceOver adjusts it by swiping
/// up or down.
struct SpeechRateControl: View {
    @Environment(\.theme) private var theme
    /// The profile's rate, 0 slowest to 1 fastest.
    let rate: Double
    let onChange: (Double) -> Void

    static let stepNames = ["Slowest", "Slow", "Medium", "Fast", "Fastest"]
    private static let thumbSide: Double = 28
    private static let trackHeight: Double = 6
    private static let tickSide: Double = 4

    private var lastStep: Int { Self.stepNames.count - 1 }

    /// The nearest step to the saved rate.
    private var step: Int {
        let nearest = Int((min(max(rate, 0), 1) * Double(lastStep)).rounded())
        return min(max(nearest, 0), lastStep)
    }

    var body: some View {
        GeometryReader { proxy in
            let usable = max(proxy.size.width - Self.thumbSide, 1)
            let fraction = min(max(rate, 0), 1)
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(theme.colors.surfaceSunken)
                    .frame(width: usable, height: Self.trackHeight)
                    .offset(x: Self.thumbSide / 2)
                Capsule()
                    .fill(theme.colors.primary)
                    .frame(width: usable * fraction, height: Self.trackHeight)
                    .offset(x: Self.thumbSide / 2)
                ForEach(0...lastStep, id: \.self) { index in
                    Circle()
                        .fill(theme.colors.inkMuted)
                        .frame(width: Self.tickSide, height: Self.tickSide)
                        .offset(x: Self.thumbSide / 2 + usable * Double(index) / Double(lastStep) - Self.tickSide / 2)
                }
                Circle()
                    .fill(theme.colors.teal)
                    .overlay(Circle().strokeBorder(theme.colors.surface, lineWidth: 3))
                    .frame(width: Self.thumbSide, height: Self.thumbSide)
                    .offset(x: usable * fraction)
            }
            .frame(width: proxy.size.width, height: proxy.size.height, alignment: .leading)
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        let position = (value.location.x - Self.thumbSide / 2) / usable
                        let nearest = Int((min(max(position, 0), 1) * Double(lastStep)).rounded())
                        select(nearest)
                    }
            )
        }
        .frame(height: Spacing.touchMin)
        .accessibilityElement()
        .accessibilityLabel("Speech rate")
        .accessibilityValue(Self.stepNames[step])
        .accessibilityAdjustableAction { direction in
            switch direction {
            case .increment: select(step + 1)
            case .decrement: select(step - 1)
            @unknown default: break
            }
        }
    }

    private func select(_ index: Int) {
        let clamped = min(max(index, 0), lastStep)
        let newRate = Double(clamped) / Double(lastStep)
        if abs(newRate - rate) > 0.001 {
            onChange(newRate)
        }
    }
}
