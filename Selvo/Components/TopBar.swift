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
            // The clear spacer keeps the slot 96pt wide even when it is empty, so the title
            // stays centered.
            ZStack(alignment: .leading) {
                Color.clear.frame(width: ComponentMetrics.topBarSlotWidth, height: 1)
                leading()
            }
            .frame(minWidth: ComponentMetrics.topBarSlotWidth, alignment: .leading)
            Text(title)
                .textStyle(TypeScale.heading)
                .foregroundStyle(theme.colors.ink)
                .lineLimit(1)
                .truncationMode(.tail)
                .frame(maxWidth: .infinity)
                .accessibilityAddTraits(.isHeader)
            ZStack(alignment: .trailing) {
                Color.clear.frame(width: ComponentMetrics.topBarSlotWidth, height: 1)
                trailing()
            }
            .frame(minWidth: ComponentMetrics.topBarSlotWidth, alignment: .trailing)
        }
        .frame(minHeight: ComponentMetrics.topBarHeight)
        // Screen chrome stops growing at the largest standard size, like the system bars, so
        // Back, the title and Help stay readable at accessibility sizes.
        .dynamicTypeSize(...DynamicTypeSize.xxxLarge)
    }
}
