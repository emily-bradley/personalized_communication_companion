import SwiftUI
import SelvoCore

/// Page dots under a tile grid: 8pt with an 8pt gap, teal for the current page. The whole row
/// is one 44pt tall target that goes to the next page, wrapping to the first. VoiceOver reads
/// the row as one adjustable "Page 1 of 2" element.
struct PageDots: View {
    @Environment(\.theme) private var theme
    @Environment(\.accessibilityDifferentiateWithoutColor) private var differentiateWithoutColor
    let count: Int
    @Binding var page: Int

    private static let dotSide: Double = 8

    var body: some View {
        HStack(spacing: Spacing.space2) {
            ForEach(0..<count, id: \.self) { index in
                dot(isCurrent: index == page)
                    .frame(width: Self.dotSide, height: Self.dotSide)
            }
        }
        .frame(maxWidth: .infinity, minHeight: Spacing.touchMin)
        .contentShape(Rectangle())
        .onTapGesture {
            page = (page + 1) % max(count, 1)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Page \(page + 1) of \(count)")
        .accessibilityAdjustableAction { direction in
            switch direction {
            case .increment: page = min(page + 1, count - 1)
            case .decrement: page = max(page - 1, 0)
            @unknown default: break
            }
        }
    }

    /// With Differentiate Without Color on, the other pages are hollow rings, so the current
    /// page is the only filled dot and does not rely on teal alone.
    @ViewBuilder private func dot(isCurrent: Bool) -> some View {
        if isCurrent {
            Circle().fill(theme.colors.teal)
        } else if differentiateWithoutColor {
            Circle().strokeBorder(theme.colors.borderStrong, lineWidth: 1.5)
        } else {
            Circle().fill(theme.colors.borderStrong)
        }
    }
}
