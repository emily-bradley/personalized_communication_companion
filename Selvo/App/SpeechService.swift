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

    func speak(_ text: String, profile: Profile?) {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
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
        isSpeaking = true
        synthesizer.speak(utterance)
    }

    func stop() {
        synthesizer.stopSpeaking(at: .immediate)
    }

    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        DispatchQueue.main.async {
            self.isSpeaking = false
            self.spokenCount += 1
        }
    }

    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        DispatchQueue.main.async { self.isSpeaking = false }
    }
}
