import SwiftUI
import SelvoCore

/// Page dots under a tile grid: 8pt, teal for the current page. Each dot is a 44pt target, and
/// VoiceOver reads the row as one adjustable "Page 1 of 2" element.
struct PageDots: View {
    @Environment(\.theme) private var theme
    let count: Int
    @Binding var page: Int

    var body: some View {
        HStack(spacing: 0) {
            ForEach(0..<count, id: \.self) { index in
                Button {
                    page = index
                } label: {
                    Circle()
                        .fill(index == page ? theme.colors.teal : theme.colors.borderStrong)
                        .frame(width: 8, height: 8)
                        .frame(width: Spacing.touchMin, height: Spacing.touchMin)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
        }
        .frame(maxWidth: .infinity)
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
}
