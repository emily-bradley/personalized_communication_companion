import AVFoundation
import Observation
import UIKit
import SelvoCore

/// Speaks the message with AVSpeechSynthesizer using the profile's voice and rate.
/// Everything stays on the phone.
@Observable
final class SpeechService: NSObject, AVSpeechSynthesizerDelegate {
    private let synthesizer = AVSpeechSynthesizer()
    /// True while a message is being spoken.
    private(set) var isSpeaking = false
    /// Increments each time a message finishes, so views can show the Spoken state.
    private(set) var spokenCount = 0
    /// The message playing now, so a cancelled earlier one does not clear isSpeaking.
    @ObservationIgnored private var current: AVSpeechUtterance?

    override init() {
        super.init()
        synthesizer.delegate = self
    }

    /// Maps the profile's 0...1 speech rate onto a comfortable part of the synthesizer's range.
    static func utteranceRate(for profileRate: Double) -> Float {
        let low = AVSpeechUtteranceMinimumSpeechRate + 0.25 * (AVSpeechUtteranceDefaultSpeechRate - AVSpeechUtteranceMinimumSpeechRate)
        let high = AVSpeechUtteranceDefaultSpeechRate + 0.35 * (AVSpeechUtteranceMaximumSpeechRate - AVSpeechUtteranceDefaultSpeechRate)
        let clamped = Float(min(max(profileRate, 0), 1))
        return low + (high - low) * clamped
    }

    /// Speaks `text` and returns true. A second Speak while the same message is still playing
    /// is ignored (returns false), so a quick double tap gives one haptic and one message.
    @discardableResult
    func speak(_ text: String, profile: Profile?) -> Bool {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return false }
        if isSpeaking && current?.speechString == trimmed {
            return false
        }
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
        }
        let session = AVAudioSession.sharedInstance()
        try? session.setCategory(.playback, mode: .spokenAudio, options: [.duckOthers])
        try? session.setActive(true)

        let utterance = AVSpeechUtterance(string: trimmed)
        utterance.rate = Self.utteranceRate(for: profile?.speechRate ?? 0.5)
        if let id = profile?.voiceIdentifier, let voice = AVSpeechSynthesisVoice(identifier: id) {
            utterance.voice = voice
        } else {
            utterance.voice = AVSpeechSynthesisVoice(language: AVSpeechSynthesisVoice.currentLanguageCode())
        }
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        current = utterance
        isSpeaking = true
        synthesizer.speak(utterance)
        return true
    }

    func stop() {
        synthesizer.stopSpeaking(at: .immediate)
    }

    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        DispatchQueue.main.async {
            // After a quick second Speak, a newer message is already playing.
            if utterance === self.current { self.isSpeaking = false }
            self.spokenCount += 1
        }
    }

    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        DispatchQueue.main.async {
            if utterance === self.current { self.isSpeaking = false }
        }
    }
}
