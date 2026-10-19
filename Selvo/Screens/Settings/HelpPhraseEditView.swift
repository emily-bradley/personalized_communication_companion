import SwiftUI
import SelvoCore

/// The help message editor for supporters, opened from Settings: the large heading and the
/// sentence under it, with a small live preview of the attention screen. Saves on every change.
struct HelpPhraseEditView: View {
    @Environment(AppModel.self) private var model
    @Environment(\.theme) private var theme

    var body: some View {
        let title = model.profile?.helpTitle ?? ""
        let phrase = model.profile?.helpPhrase ?? ""

        Screen {
            TopBar(title: "Help message") {
                BackButton(action: goBack)
            } trailing: {
                EmptyView()
            }

            ScrollsWhenNeeded {
                VStack(alignment: .leading, spacing: Spacing.space4) {
                    Text("This shows in large type when you tap Help, then Yes, show it.")
                        .textStyle(TypeScale.caption)
                        .foregroundStyle(theme.colors.inkMuted)
                        .fixedSize(horizontal: false, vertical: true)

                    field(
                        label: "Large heading",
                        prompt: "I need help.",
                        text: Binding(
                            get: { model.profile?.helpTitle ?? "" },
                            set: { newValue in model.update { $0.helpTitle = newValue } }
                        )
                    )

                    field(
                        label: "Sentence under it",
                        prompt: "Who to call, or what to do",
                        text: Binding(
                            get: { model.profile?.helpPhrase ?? "" },
                            set: { newValue in model.update { $0.helpPhrase = newValue } }
                        )
                    )

                    SetupSectionLabel(title: "Preview")
                    preview(title: title, phrase: phrase)
                }
                .padding(.vertical, Spacing.space1)
            }
        }
        .toolbar(.hidden, for: .navigationBar)
    }

    /// A labeled multiline field in a raised box with a border-strong edge, radius 16.
    private func field(label: String, prompt: String, text: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: Spacing.space2) {
            SetupSectionLabel(title: label)
            TextField("", text: text, prompt: Text(prompt).foregroundColor(theme.colors.inkMuted), axis: .vertical)
                .textStyle(TypeScale.body)
                .foregroundStyle(theme.colors.ink)
                .lineLimit(1...5)
                .textInputAutocapitalization(.sentences)
                .padding(.horizontal, Spacing.space4)
                .padding(.vertical, Spacing.space3)
                .frame(maxWidth: .infinity, minHeight: SetupMetrics.inputHeight, alignment: .leading)
                .background(RoundedRectangle(cornerRadius: Radius.md).fill(theme.colors.surfaceRaised))
                .overlay(RoundedRectangle(cornerRadius: Radius.md).strokeBorder(theme.colors.borderStrong, lineWidth: 1))
                .accessibilityLabel(label)
        }
    }

    /// The attention screen in miniature: danger ground, on-primary type, radius 24.
    private func preview(title: String, phrase: String) -> some View {
        VStack(alignment: .leading, spacing: Spacing.space3) {
            Text(title)
                .textStyle(TypeScale.heading)
                .fixedSize(horizontal: false, vertical: true)
            if !phrase.isEmpty {
                Text(phrase)
                    .textStyle(TypeScale.body)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .foregroundStyle(theme.colors.onPrimary)
        .padding(Spacing.space6)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(RoundedRectangle(cornerRadius: Radius.lg).fill(theme.colors.danger))
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(phrase.isEmpty ? "Preview: \(title)" : "Preview: \(title) \(phrase)")
    }

    private func goBack() {
        if !model.path.isEmpty {
            model.path.removeLast()
        }
    }
}
