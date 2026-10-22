import SwiftUI
import UIKit
import SelvoCore

/// Listen (App-Listen): the orb, a constant Listening indicator, what was just heard on a
/// raised card, and replies from saved phrases on request. Listening starts when the screen
/// appears and stops when it goes away. Nothing on this screen times out.
///
/// Speaker detection does not exist yet, so the card's caption reads "Heard". The preview
/// values let screenshot tests show the artboard state without a microphone; when they are
/// given, the microphone is never started.
struct ListenView: View {
    @Environment(AppModel.self) private var model
    @Environment(\.theme) private var theme
    @Environment(\.openURL) private var openURL
    @Environment(\.dynamicTypeSize) private var typeSize

    @State private var listener = SpeechListener()
    /// The three replies, once Show replies is tapped. They do not change on their own.
    @State private var replies: [Suggestion] = []
    @State private var selectedReply: Int?
    /// Set when listening should start once Selvo finishes speaking.
    @State private var listensAfterSpeech = false

    private let previewHeard: String?
    private let previewSpeaker: String?
    private let saved = SavedPhraseProvider()

    init(previewHeard: String? = nil, previewSpeaker: String? = nil) {
        self.previewHeard = previewHeard
        self.previewSpeaker = previewSpeaker
    }

    private var isPreview: Bool { previewHeard != nil || previewSpeaker != nil }
    private var status: SpeechListener.Status { isPreview ? .listening : listener.state }
    private var heard: String { previewHeard ?? listener.heardText }
    private var speaker: String { previewSpeaker ?? "Heard" }
    private var showsReplies: Bool { !replies.isEmpty }

    private var showsHeardCard: Bool {
        switch status {
        case .denied, .unavailable: return false
        default: return true
        }
    }

    var body: some View {
        Screen {
            TopBar(title: "Listen") {
                BackButton { leave() }
            } trailing: {
                HelpButton { model.open(.help) }
            }

            ScrollsWhenNeeded(inset: Spacing.space1, alignment: .center, drawsOutside: true) {
                middle
            }
            .frame(maxHeight: .infinity)

            if showsReplies {
                QuietButton(title: controlTitle, fillsWidth: true) { controlAction() }
                    .accessibilityHint(controlHint)
                    .dynamicTypeSize(...DynamicTypeSize.xxxLarge)
                PrimaryButton(
                    title: "Speak",
                    isEnabled: selectedReply != nil,
                    accessibilityHint: "Says the reply you chose out loud",
                    showsSoundBars: true
                ) {
                    speak()
                }
            } else {
                VStack(spacing: Spacing.space2) {
                    Text("Replies are on their way. Saved phrases still work.")
                        .textStyle(TypeScale.caption)
                        .foregroundStyle(theme.colors.inkMuted)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                        .frame(maxWidth: .infinity)
                    QuietButton(
                        title: "Show replies",
                        fillsWidth: true,
                        height: ComponentMetrics.largeQuietButtonHeight
                    ) { showReplies() }
                        .accessibilityHint("Shows three replies you can choose")
                }
                // The caption and Show replies grow together and stop at accessibility1, so
                // the heard text keeps the space.
                .dynamicTypeSize(...DynamicTypeSize.accessibility1)
                PrimaryButton(title: controlTitle, accessibilityHint: controlHint) {
                    controlAction()
                }
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .task { startListening() }
        .onDisappear {
            listensAfterSpeech = false
            listener.stop()
        }
        .onChange(of: model.speech.isSpeaking) { _, speaking in
            if !speaking && listensAfterSpeech {
                listensAfterSpeech = false
                listener.start()
            }
        }
        .onChange(of: listener.state) { _, newState in
            announce(newState)
        }
    }

    // MARK: Parts

    private var middle: some View {
        VStack(spacing: Spacing.space6) {
            // The one glowing object. It is still: no pulsing, so Reduce Motion has nothing to stop.
            // Smaller at accessibility text sizes so the heard text keeps the space.
            Orb(diameter: showsReplies || typeSize.isAccessibilitySize ? 96 : 160)
            ListeningStatus(status: status) { openSettings() }
            if showsHeardCard {
                HeardCard(speaker: speaker, text: heard)
            }
            if showsReplies {
                VStack(spacing: Spacing.space3) {
                    ForEach(Array(replies.enumerated()), id: \.element.id) { index, reply in
                        SuggestionCard(
                            text: reply.text,
                            caption: reply.caption(personName: personName),
                            isSelected: selectedReply == index
                        ) {
                            select(index)
                        }
                        .accessibilityHint("Puts this in your message")
                    }
                }
            }
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: Listening control

    /// The pinned control: Stop listening while listening, Listen again after Speak paused it,
    /// and Done when listening cannot run.
    private var controlTitle: String {
        switch status {
        case .listening, .starting: return "Stop listening"
        case .idle: return "Listen again"
        case .denied, .unavailable: return "Done"
        }
    }

    private var controlHint: String {
        switch status {
        case .listening, .starting: return "Stops listening and goes back"
        case .idle: return "Starts listening again"
        case .denied, .unavailable: return "Goes back"
        }
    }

    private func controlAction() {
        switch status {
        case .idle:
            startListening()
        default:
            leave()
        }
    }

    // MARK: Replies

    private var personName: String { model.profile?.name ?? "you" }

    private var context: SuggestionContext {
        let trimmed = heard.trimmingCharacters(in: .whitespacesAndNewlines)
        let heardText: String? = trimmed.isEmpty ? nil : trimmed
        if let profile = model.profile {
            return SuggestionContext(profile: profile, tile: nil, heardText: heardText)
        }
        return SuggestionContext(personName: personName, heardText: heardText)
    }

    private func showReplies() {
        replies = saved.phrases(for: context, count: SuggestionStack.size, excluding: [])
        selectedReply = nil
    }

    private func select(_ index: Int) {
        guard replies.indices.contains(index) else { return }
        selectedReply = index
        model.selectedTile = nil
        model.message = replies[index].text
    }

    /// Starts listening, or waits until Selvo finishes speaking so the voice is not cut off
    /// and the microphone does not hear it.
    private func startListening() {
        guard !isPreview else { return }
        if model.speech.isSpeaking {
            listensAfterSpeech = true
        } else {
            listener.start()
        }
    }

    /// Stops listening first so the phone does not hear its own voice, then speaks.
    private func speak() {
        listensAfterSpeech = false
        listener.stop()
        model.speak()
    }

    // MARK: Navigation and system

    private func leave() {
        listensAfterSpeech = false
        listener.stop()
        if !model.path.isEmpty {
            model.path.removeLast()
        }
    }

    private func openSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            openURL(url)
        }
    }

    /// VoiceOver hears when listening begins or cannot begin. Not after Speak, so it never
    /// talks over the spoken message.
    private func announce(_ state: SpeechListener.Status) {
        switch state {
        case .listening:
            UIAccessibility.post(notification: .announcement, argument: "Listening")
        case .denied(let message):
            UIAccessibility.post(notification: .announcement, argument: message)
        case .unavailable:
            UIAccessibility.post(notification: .announcement, argument: ListeningStatus.unavailableMessage)
        case .idle, .starting:
            break
        }
    }
}
