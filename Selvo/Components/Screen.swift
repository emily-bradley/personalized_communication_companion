import SwiftUI
import SelvoCore

/// Every screen sits on the surface color with 16pt side margins and 16pt between sections.
struct Screen<Content: View>: View {
    @Environment(\.theme) private var theme
    @ViewBuilder var content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.space4) {
            content()
        }
        .padding(.horizontal, Spacing.space4)
        .padding(.top, Spacing.space2)
        .padding(.bottom, Spacing.space2)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(theme.colors.surface.ignoresSafeArea())
        .foregroundStyle(theme.colors.ink)
    }
}
