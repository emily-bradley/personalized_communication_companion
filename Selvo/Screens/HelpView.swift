import SwiftUI
import SelvoCore

/// Help (App-Help). Two taps, always: a confirm screen first, then the attention screen with
/// the person's phrase in large type on the danger ground. Nothing is sent anywhere and
/// nothing times out; the attention screen stays until Done.
struct HelpView: View {
    @Environment(AppModel.self) private var model
    @Environment(\.theme) private var theme
    @State private var isShowingAttention: Bool

    /// `startsOnAttention` lets screenshot tests render the attention screen directly.
    init(startsOnAttention: Bool = false) {
        _isShowingAttention = State(initialValue: startsOnAttention)
    }

    var body: some View {
        ZStack {
            if isShowingAttention {
                HelpAttentionView(
                    title: model.profile?.helpTitle ?? "I need help.",
                    phrase: model.profile?.helpPhrase ?? "",
                    done: goBack
                )
                .transition(.opacity)
                .onAppear { model.isShowingHelpAttention = true }
                .onDisappear { model.isShowingHelpAttention = false }
            } else {
                confirm
                    .transition(.opacity)
            }
        }
        .toolbar(.hidden, for: .navigationBar)
    }

    private var confirm: some View {
        Screen {
            TopBar(title: "Help") {
                BackButton(action: goBack)
            } trailing: {
                EmptyView()
            }

            VStack(alignment: .leading, spacing: Spacing.space4) {
                Spacer(minLength: 0)
                Text("Show the help screen?")
                    .textStyle(TypeScale.message)
                    .foregroundStyle(theme.colors.ink)
                    .minimumScaleFactor(0.5)
                    .accessibilityAddTraits(.isHeader)
                Text("It fills the screen with your phrase in large type so people around you can read it. Nothing is sent anywhere.")
                    .textStyle(TypeScale.body)
                    .foregroundStyle(theme.colors.inkMuted)
                    .minimumScaleFactor(0.5)
                Spacer(minLength: 0)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
            .layoutPriority(1)

            QuietButton(title: "Cancel", fillsWidth: true, height: ComponentMetrics.largeQuietButtonHeight, action: goBack)

            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                    isShowingAttention = true
                }
            } label: {
                Text("Yes, show it")
                    .textStyle(TypeScale.primaryAction)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                    .frame(maxWidth: .infinity, minHeight: ComponentMetrics.primaryButtonHeight)
            }
            .buttonStyle(HelpFilledButtonStyle(theme: theme))
            .accessibilityHint("Fills the screen with your help message")
        }
    }

    private func goBack() {
        if !model.path.isEmpty {
            model.path.removeLast()
        }
    }
}
