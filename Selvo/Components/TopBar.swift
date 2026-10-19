import SwiftUI
import SelvoCore

/// The bar at the top of every screen: a 96pt left slot (Back or the wordmark), a centered
/// heading, and a 96pt right slot (Help, Clear, Settings).
struct TopBar<Leading: View, Trailing: View>: View {
    @Environment(\.theme) private var theme
    let title: String
    @ViewBuilder var leading: () -> Leading
    @ViewBuilder var trailing: () -> Trailing

    var body: some View {
        HStack(spacing: Spacing.space2) {
            leading()
                .frame(minWidth: ComponentMetrics.topBarSlotWidth, alignment: .leading)
            Text(title)
                .textStyle(TypeScale.heading)
                .foregroundStyle(theme.colors.ink)
                .lineLimit(1)
                .truncationMode(.tail)
                .frame(maxWidth: .infinity)
                .accessibilityAddTraits(.isHeader)
            trailing()
                .frame(minWidth: ComponentMetrics.topBarSlotWidth, alignment: .trailing)
        }
        .frame(minHeight: ComponentMetrics.topBarHeight)
    }
}
