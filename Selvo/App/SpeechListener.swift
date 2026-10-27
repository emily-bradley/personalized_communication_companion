import AVFoundation
import Foundation
import Observation
import os
import Speech

/// Turns what people nearby say into text for the Listen screen.
///
/// Uses the Speech framework with on-device recognition whenever the phone supports it, so
/// nothing heard leaves the phone. It makes no network calls of its own and never logs what it
/// hears. Safe in the Simulator and in tests: if permission is denied or there is no
/// microphone input, it reports that instead of crashing.
///
/// Recognition sessions end by themselves after a pause. While listening, a new one starts
/// right away, so listening only stops when `stop()` is called.
@Observable
final class SpeechListener {
    enum Status: Equatable {
        case idle
        /// Asking for permission or starting the microphone.
        case starting
        case listening
        /// Permission was not given. The message says what to turn on, in plain words.
        case denied(String)
        /// No recognizer for this language, or no microphone input (as in some Simulators).
        case unavailable
    }

    private(set) var state: Status = .idle
    /// The latest thing heard. Kept on screen until someone speaks again.
    private(set) var heardText: String = ""

    static let speechDeniedMessage = "Selvo needs speech recognition to show what people say to you. You can turn it on in Settings."
    static let microphoneDeniedMessage = "Selvo needs the microphone to show what people say to you. You can turn it on in Settings."

    /// Says why listening could not run, for the Mac's Console and CI. Never what was heard.
    @ObservationIgnored private let log = Logger(subsystem: "com.emilykenney.selvo", category: "listen")

    @ObservationIgnored private var engine: AVAudioEngine?
    @ObservationIgnored private var request: SFSpeechAudioBufferRecognitionRequest?
    @ObservationIgnored private var task: SFSpeechRecognitionTask?
    @ObservationIgnored private var tapInstalled = false
    /// True while the audio session is set up for recording by this class.
    @ObservationIgnored private var changedSession = false
    /// Bumped on every start, stop and restart so late callbacks from an earlier session are ignored.
    @ObservationIgnored private var generation = 0
    @ObservationIgnored private var taskStartedAt = Date()
    /// Recognition sessions in a row that failed almost at once. Stops a restart loop.
    @ObservationIgnored private var quickFailures = 0

    init() {}

    /// Asks for permission if needed, then starts listening. Calling it while already
    /// listening does nothing.
    func start() {
        if state == .listening || state == .starting { return }
        generation += 1
        let current = generation
        quickFailures = 0
        state = .starting
        requestPermissions { [weak self] denial in
            guard let self, self.generation == current else { return }
            if let denial {
                self.state = .denied(denial)
            } else {
                self.beginRecognition()
            }
        }
    }

    /// Stops listening, removes the microphone tap, and puts the audio session back to
    /// playback so Speak works.
    func stop() {
        generation += 1
        stopAudio()
        restorePlayback()
        // Only the state, never what was heard, so CI can tell whether Stop reached Selvo.
        log.notice("Stopped listening")
        if state == .listening || state == .starting {
            state = .idle
        }
    }

    // MARK: Permissions

    /// Calls `done` on the main queue with nil when both permissions are given, or the
    /// message to show when one is not.
    private func requestPermissions(_ done: @escaping (String?) -> Void) {
        SFSpeechRecognizer.requestAuthorization { status in
            guard status == .authorized else {
                DispatchQueue.main.async { done(SpeechListener.speechDeniedMessage) }
                return
            }
            AVAudioApplication.requestRecordPermission { granted in
                DispatchQueue.main.async {
                    done(granted ? nil : SpeechListener.microphoneDeniedMessage)
                }
            }
        }
    }

    // MARK: Recognition

    private func beginRecognition() {
        guard let recognizer = SFSpeechRecognizer(), recognizer.isAvailable else {
            becomeUnavailable("no speech recognizer for this language, or it is not available now")
            return
        }

        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(.record, mode: .measurement, options: [.duckOthers])
            try session.setActive(true, options: .notifyOthersOnDeactivation)
            changedSession = true
        } catch {
            becomeUnavailable("the audio session could not switch to recording")
            return
        }

        let engine = AVAudioEngine()
        let input = engine.inputNode
        let format = input.outputFormat(forBus: 0)
        // No input hardware (for example a Simulator without a microphone) reports a zero
        // sample rate; installing a tap with that format would crash.
        guard format.sampleRate > 0, format.channelCount > 0 else {
            becomeUnavailable("no microphone input")
            return
        }

        let request = SFSpeechAudioBufferRecognitionRequest()
        request.shouldReportPartialResults = true
        request.addsPunctuation = true
        // Keeps everything on the phone whenever the phone can recognize speech by itself.
        request.requiresOnDeviceRecognition = recognizer.supportsOnDeviceRecognition
        log.notice("Starting recognition, on device: \(recognizer.supportsOnDeviceRecognition, privacy: .public), sample rate \(format.sampleRate, privacy: .public)")

        input.installTap(onBus: 0, bufferSize: 1024, format: format) { buffer, _ in
            request.append(buffer)
        }
        self.engine = engine
        self.request = request
        tapInstalled = true

        engine.prepare()
        do {
            try engine.start()
        } catch {
            becomeUnavailable("the audio engine did not start")
            return
        }

        let current = generation
        taskStartedAt = Date()
        task = recognizer.recognitionTask(with: request) { [weak self] result, error in
            let text = result?.bestTranscription.formattedString
            let isFinal = result?.isFinal ?? false
            let failed = error != nil
            if let error = error as NSError? {
                self?.log.notice("Recognition session ended: \(error.domain, privacy: .public) \(error.code, privacy: .public)")
            }
            DispatchQueue.main.async {
                guard let self, self.generation == current else { return }
                if let text, !text.isEmpty {
                    self.heardText = text
                    self.quickFailures = 0
                }
                if isFinal || failed {
                    self.sessionEnded(failed: failed)
                }
            }
        }
        state = .listening
    }

    /// A recognition session ended by itself. Starts a new one so listening never times out,
    /// unless sessions keep failing the moment they start.
    private func sessionEnded(failed: Bool) {
        if failed && Date().timeIntervalSince(taskStartedAt) < 1 {
            quickFailures += 1
        }
        if quickFailures >= 3 {
            becomeUnavailable("recognition sessions failed three times in a row as they started")
            return
        }
        generation += 1
        let current = generation
        stopAudio()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            guard let self, self.generation == current else { return }
            self.beginRecognition()
        }
    }

    private func becomeUnavailable(_ reason: String) {
        log.error("Listening is not available: \(reason, privacy: .public)")
        generation += 1
        stopAudio()
        restorePlayback()
        state = .unavailable
    }

    private func stopAudio() {
        if let engine {
            if engine.isRunning {
                engine.stop()
            }
            if tapInstalled {
                engine.inputNode.removeTap(onBus: 0)
            }
        }
        tapInstalled = false
        request?.endAudio()
        task?.cancel()
        task = nil
        request = nil
        engine = nil
    }

    /// Puts the audio session back the way Speak expects it. Only touches the session if this
    /// class changed it, so a message being spoken is never cut off.
    private func restorePlayback() {
        guard changedSession else { return }
        changedSession = false
        let session = AVAudioSession.sharedInstance()
        try? session.setCategory(.playback, mode: .spokenAudio, options: [.duckOthers])
        try? session.setActive(false, options: .notifyOthersOnDeactivation)
    }
}
