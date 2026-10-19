import SwiftUI
import SelvoCore

/// Settings (App-Settings): text size with a live preview, theme, speech rate, reading font,
/// supporter editing and voice. Every change saves straight away; theme and font apply live
/// because RootView reads the model's theme.
struct SettingsView: View {
    @Environment(AppModel.self) private var model
    @Environment(\.theme) private var theme
    @Environment(\.dynamicTypeSize) private var typeSize
    @State private var isChoosingVoice = false

    static let previewText = "Are we eating soon?"

    var body: some View {
        let profile = model.profile
        let textSize = profile?.textSize ?? .standard
        let themeID = profile?.theme ?? theme.id
        let readingFont = profile?.readingFont ?? theme.readingFont
        let voiceName = VoiceCatalog.name(for: profile?.voiceIdentifier) ?? "default"

        Screen {
            TopBar(title: "Settings") {
                BackButton(action: goBack)
            } trailing: {
                EmptyView()
            }

            // The 8pt inset leaves room for the 3pt selection ring drawn 2pt outside a swatch.
            ScrollsWhenNeeded(inset: Spacing.space2) {
                VStack(alignment: .leading, spacing: Spacing.space6) {
                    textSizeSection(textSize)
                    themeSection(themeID, personName: profile?.name)
                    speechRateSection(profile?.speechRate ?? 0.5)
                    readingFontSection(themeID: themeID, selected: readingFont)
                    supporterSection
                }
                .padding(.vertical, Spacing.space1)
            }

            voiceRow(voiceName)
        }
        .toolbar(.hidden, for: .navigationBar)
        .sheet(isPresented: $isChoosingVoice) {
            VoicePickerSheet()
                .environment(model)
                .environment(\.theme, theme)
        }
    }

    // MARK: Sections

    private func textSizeSection(_ selected: TextSize) -> some View {
        VStack(alignment: .leading, spacing: Spacing.space3) {
            SetupSectionLabel(title: "Text size")
            HStack(spacing: Spacing.space2) {
                ForEach(TextSize.allCases, id: \.self) { size in
                    SetupChoicePill(
                        title: "A",
                        style: sampleStyle(for: size),
                        accessibilityName: sizeName(for: size),
                        isSelected: selected == size
                    ) {
                        model.update { $0.textSize = size }
                    }
                }
            }
            // The three A samples are fixed sizes; they stop growing like the screen chrome.
            .dynamicTypeSize(...DynamicTypeSize.xxxLarge)

            Text(Self.previewText)
                .textStyle(TypeScale.message)
                .foregroundStyle(theme.colors.ink)
                .fixedSize(horizontal: false, vertical: true)
                .padding(Spacing.space4)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(RoundedRectangle(cornerRadius: Radius.md).fill(theme.colors.surfaceRaised))
                .environment(\.dynamicTypeSize, max(typeSize, selected.minimumDynamicType))
                .accessibilityElement(children: .ignore)
                .accessibilityLabel("Preview: \(Self.previewText)")
        }
    }

    private func themeSection(_ selected: ThemeID, personName: String?) -> some View {
        VStack(alignment: .leading, spacing: Spacing.space3) {
            SetupSectionLabel(title: "Theme")
            HStack(spacing: Spacing.space3) {
                ForEach(ThemeID.allCases, id: \.self) { id in
                    SetupThemeSwatch(themeID: id, isSelected: selected == id) {
                        model.update { $0.theme = id }
                    }
                }
            }
            caption("Both shown side by side. \(personName ?? "You") chose \(selected.displayName) at setup.")
        }
    }

    private func speechRateSection(_ rate: Double) -> some View {
        VStack(alignment: .leading, spacing: Spacing.space3) {
            SetupSectionLabel(title: "Speech rate")
            HStack(spacing: Spacing.space3) {
                Text("Slow")
                    .textStyle(TypeScale.caption)
                    .foregroundStyle(theme.colors.inkMuted)
                    .fixedSize()
                SpeechRateControl(rate: rate) { newRate in
                    model.update { $0.speechRate = newRate }
                }
                Text("Fast")
                    .textStyle(TypeScale.caption)
                    .foregroundStyle(theme.colors.inkMuted)
                    .fixedSize()
            }
        }
    }

    private func readingFontSection(themeID: ThemeID, selected: ReadingFont) -> some View {
        VStack(alignment: .leading, spacing: Spacing.space3) {
            SetupSectionLabel(title: "Reading font")
            HStack(spacing: Spacing.space2) {
                ForEach(ReadingFont.allCases, id: \.self) { font in
                    SetupChoicePill(
                        title: shortName(for: font),
                        accessibilityName: "\(font.displayName) font",
                        isSelected: selected == font
                    ) {
                        model.update { $0.readingFont = font }
                    }
                    // Each label is drawn in its own font: same colors, that font's theme.
                    .environment(\.theme, Theme(themeID, readingFont: font))
                }
            }
            caption("Atkinson Hyperlegible was tested with low-vision readers.")
        }
    }

    /// Editing for supporters: each tile category and the help message.
    private var supporterSection: some View {
        VStack(alignment: .leading, spacing: Spacing.space3) {
            SetupSectionLabel(title: "For supporters")
            ForEach(TileCategory.allCases, id: \.self) { category in
                supporterRow("Edit \(category.title)", route: .editTiles(category))
            }
            supporterRow("Help message", route: .editHelpPhrase)
        }
    }

    /// A 56pt outlined pill with a chevron, like the Voice row.
    private func supporterRow(_ title: String, route: Route) -> some View {
        Button {
            model.open(route)
        } label: {
            HStack(spacing: Spacing.space2) {
                Text(title)
                    .textStyle(TypeScale.label)
                    .foregroundStyle(theme.colors.ink)
                    .fixedSize(horizontal: false, vertical: true)
                Spacer(minLength: 0)
                Image(systemName: "chevron.right")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(theme.colors.inkMuted)
                    .accessibilityHidden(true)
            }
            .padding(.horizontal, Spacing.space6)
            .frame(maxWidth: .infinity, minHeight: SetupMetrics.inputHeight)
            .overlay(Capsule().strokeBorder(theme.colors.borderStrong, lineWidth: 1))
            .contentShape(Capsule())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(title)
    }

    /// The Voice row at the bottom, a 56pt outlined pill like the artboard.
    private func voiceRow(_ name: String) -> some View {
        Button {
            isChoosingVoice = true
        } label: {
            Text("Voice: \(name)")
                .textStyle(TypeScale.label)
                .foregroundStyle(theme.colors.ink)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
                .padding(.horizontal, Spacing.space6)
                .frame(maxWidth: .infinity, minHeight: SetupMetrics.inputHeight)
                .overlay(Capsule().strokeBorder(theme.colors.borderStrong, lineWidth: 1))
                .contentShape(Capsule())
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Voice: \(name)")
        .accessibilityHint("Opens the list of voices")
    }

    // MARK: Helpers

    private func caption(_ text: String) -> some View {
        Text(text)
            .textStyle(TypeScale.caption)
            .foregroundStyle(theme.colors.inkMuted)
            .fixedSize(horizontal: false, vertical: true)
    }

    private func sampleStyle(for size: TextSize) -> TypeStyle {
        switch size {
        case .standard: return TypeScale.label
        case .large: return TypeScale.heading
        case .larger: return TypeScale.message
        }
    }

    private func sizeName(for size: TextSize) -> String {
        switch size {
        case .standard: return "Standard text size"
        case .large: return "Large text size"
        case .larger: return "Larger text size"
        }
    }

    private func shortName(for font: ReadingFont) -> String {
        switch font {
        case .lexend: return "Lexend"
        case .atkinson: return "Atkinson"
        }
    }

    private func goBack() {
        if !model.path.isEmpty {
            model.path.removeLast()
        }
    }
}
