import AVFoundation
import SwiftUI
import SelvoCore

/// The voices Selvo offers: installed voices in the phone's language, without novelty voices.
enum VoiceCatalog {
    static var languagePrefix: String {
        let code = AVSpeechSynthesisVoice.currentLanguageCode()
        return code.split(separator: "-").first.map(String.init) ?? "en"
    }

    static func voices() -> [AVSpeechSynthesisVoice] {
        AVSpeechSynthesisVoice.speechVoices()
            .filter { $0.language.hasPrefix(languagePrefix) && !$0.voiceTraits.contains(.isNoveltyVoice) }
            .sorted { $0.name < $1.name }
    }

    /// The saved voice's name, or nil when none is saved or it is no longer installed.
    static func name(for identifier: String?) -> String? {
        guard let identifier, let voice = AVSpeechSynthesisVoice(identifier: identifier) else { return nil }
        return voice.name
    }

    /// For example "English (United Kingdom), Enhanced".
    static func detail(for voice: AVSpeechSynthesisVoice) -> String {
        let language = Locale.current.localizedString(forIdentifier: voice.language) ?? voice.language
        if voice.quality == .premium { return "\(language), Premium" }
        if voice.quality == .enhanced { return "\(language), Enhanced" }
        return language
    }
}

/// The voice list sheet. Choosing a voice saves it straight away and plays a short sample.
struct VoicePickerSheet: View {
    @Environment(AppModel.self) private var model
    @Environment(\.theme) private var theme
    @Environment(\.dismiss) private var dismiss
    private let voices = VoiceCatalog.voices()

    static let sample = "This is how I sound."

    var body: some View {
        let savedName = VoiceCatalog.name(for: model.profile?.voiceIdentifier)
        Screen {
            TopBar(title: "Voice") {
                BackButton { dismiss() }
            } trailing: {
                EmptyView()
            }
            ScrollsWhenNeeded(inset: Spacing.space1) {
                VStack(alignment: .leading, spacing: Spacing.space3) {
                    VoiceRow(
                        name: "Default voice",
                        detail: "Matches the phone's language",
                        isSelected: savedName == nil
                    ) {
                        choose(nil)
                    }
                    ForEach(voices, id: \.identifier) { voice in
                        VoiceRow(
                            name: voice.name,
                            detail: VoiceCatalog.detail(for: voice),
                            isSelected: model.profile?.voiceIdentifier == voice.identifier && savedName != nil
                        ) {
                            choose(voice.identifier)
                        }
                    }
                    if voices.isEmpty {
                        Text("More voices can be added in the iPhone Settings app, under Accessibility, Spoken Content.")
                            .textStyle(TypeScale.caption)
                            .foregroundStyle(theme.colors.inkMuted)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                .padding(.vertical, Spacing.space1)
            }
        }
    }

    private func choose(_ identifier: String?) {
        model.update { $0.voiceIdentifier = identifier }
        model.speech.speak(Self.sample, profile: model.profile)
    }
}

/// One voice: its name and language, with a check and brand tint when chosen.
private struct VoiceRow: View {
    @Environment(\.theme) private var theme
    let name: String
    let detail: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: Spacing.space3) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(name)
                        .textStyle(TypeScale.label)
                        .foregroundStyle(theme.colors.ink)
                        .fixedSize(horizontal: false, vertical: true)
                    Text(detail)
                        .textStyle(TypeScale.caption)
                        .foregroundStyle(theme.colors.inkMuted)
                        .fixedSize(horizontal: false, vertical: true)
                }
                Spacer(minLength: 0)
                if isSelected {
                    Image(systemName: "checkmark")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundStyle(theme.colors.primary)
                        .accessibilityHidden(true)
                }
            }
            .padding(.vertical, Spacing.space3)
            .padding(.horizontal, Spacing.space4)
            .frame(maxWidth: .infinity, minHeight: Spacing.touchMin, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: Radius.md)
                    .fill(isSelected ? theme.colors.surfaceBrandTint : theme.colors.surfaceRaised)
            )
            .overlay(
                RoundedRectangle(cornerRadius: Radius.md)
                    .strokeBorder(theme.colors.hairline, lineWidth: isSelected ? 0 : 1)
            )
            .focusRing(isSelected, cornerRadius: Radius.md)
            .contentShape(RoundedRectangle(cornerRadius: Radius.md))
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
        .accessibilityHint("Plays a sample")
    }
}
