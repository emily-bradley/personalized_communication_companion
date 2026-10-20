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

private struct SnapshotRenderKey: EnvironmentKey {
    static let defaultValue = false
}

extension EnvironmentValues {
    /// True inside screenshot tests. ImageRenderer cannot draw ScrollView content, so views
    /// that scroll show their top part instead.
    var isSnapshotRender: Bool {
        get { self[SnapshotRenderKey.self] }
        set { self[SnapshotRenderKey.self] = newValue }
    }
}

/// A plain stack when the content fits; scrolls only when it is taller than the space.
struct ScrollsWhenNeeded<Content: View>: View {
    @Environment(\.isSnapshotRender) private var isSnapshotRender
    /// Inner padding for the scrolling copy, so focus rings stay inside the scroll clip.
    var inset: Double = 0
    /// Where the content sits when it fits. The scrolling copy always starts at the top.
    var alignment: Alignment = .top
    /// True for screens with the orb, so its glow is not cut by the edge of the scroll area.
    var drawsOutside: Bool = false
    @ViewBuilder var content: () -> Content

    var body: some View {
        if isSnapshotRender {
            // The fitting copy is not clipped, so glows and focus rings draw in full. The
            // overflowing copy ends in the same bottom fade as the live scroll view.
            ViewThatFits(in: .vertical) {
                content()
                    .frame(maxHeight: .infinity, alignment: alignment)
                content()
                    .padding(inset)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(minHeight: 0, maxHeight: .infinity, alignment: .top)
                    .mask { edgeMask }
                    .padding(.horizontal, -inset)
            }
        } else {
            ViewThatFits(in: .vertical) {
                content()
                    .frame(maxHeight: .infinity, alignment: alignment)
                ScrollView {
                    content()
                        .padding(inset)
                        // Room for the fade, so the last line can scroll fully clear of it.
                        .padding(.bottom, Self.fadeHeight)
                }
                .scrollClipDisabled(drawsOutside)
                .mask { edgeMask }
                .padding(.horizontal, -inset)
            }
        }
    }

    private static var fadeHeight: Double { Spacing.space6 }
    /// How far an orb's glow may draw past the scroll area.
    private static var glowRoom: Double { 200 }

    /// The bottom fade. With an orb, the top and sides open up so its glow is not cut, while
    /// the bottom still fades and keeps scrolled text off the pinned buttons below.
    private var edgeMask: some View {
        bottomFade
            .padding(.top, drawsOutside ? -Self.glowRoom : 0)
            .padding(.horizontal, drawsOutside ? -Self.glowRoom : 0)
    }

    /// Fades the bottom edge so a line about to scroll under a pinned button never looks cut
    /// through the glyphs, and hints that there is more below.
    private var bottomFade: some View {
        VStack(spacing: 0) {
            Rectangle()
            LinearGradient(colors: [.black, .clear], startPoint: .top, endPoint: .bottom)
                .frame(height: Self.fadeHeight)
        }
    }
}
