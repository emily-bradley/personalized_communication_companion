import AVFoundation
import Foundation
import Speech

#if compiler(>=6.2)
/// On-device transcription with SpeechAnalyzer and DictationTranscriber (iOS 26 and later).
///
/// SpeechListener uses it only in the Simulator, when the older recognizer cannot start, as in
/// iOS 26.4 and later (kLSRErrorDomain 300). Audio never leaves the phone. The first time, iOS
/// may download the on-device speech model from Apple; that download carries no audio.
@available(iOS 26.0, *)
final class DictationSession {
    private let analyzer: SpeechAnalyzer
    private let format: AVAudioFormat
    private let input: AsyncStream<AnalyzerInput>.Continuation
    private var converter: AVAudioConverter?
    private var results: Task<Void, Never>?

    private init(analyzer: SpeechAnalyzer, format: AVAudioFormat, input: AsyncStream<AnalyzerInput>.Continuation) {
        self.analyzer = analyzer
        self.format = format
        self.input = input
    }

    /// Prepares the model and starts transcribing. `onText` gets the latest thing heard (one
    /// phrase, growing as it is said); `onEnd` is called once when transcription stops by itself.
    /// Both are called on a background queue.
    static func start(onText: @escaping (String) -> Void, onEnd: @escaping (Error?) -> Void) async throws -> DictationSession {
        var found = await DictationTranscriber.supportedLocale(equivalentTo: Locale.current)
        if found == nil {
            found = await DictationTranscriber.supportedLocale(equivalentTo: Locale(identifier: "en-US"))
        }
        guard let locale = found else { throw DictationError.noLocale }
        _ = try? await AssetInventory.reserve(locale: locale)
        let transcriber = DictationTranscriber(locale: locale, preset: .progressiveLongDictation)
        if let request = try await AssetInventory.assetInstallationRequest(supporting: [transcriber]) {
            try await request.downloadAndInstall()
        }
        guard let format = await SpeechAnalyzer.bestAvailableAudioFormat(compatibleWith: [transcriber]) else {
            throw DictationError.noFormat
        }
        let analyzer = SpeechAnalyzer(modules: [transcriber])
        let (stream, input) = AsyncStream<AnalyzerInput>.makeStream()
        let session = DictationSession(analyzer: analyzer, format: format, input: input)
        do {
            try await analyzer.start(inputSequence: stream)
        } catch {
            input.finish()
            await analyzer.cancelAndFinishNow()
            throw error
        }
        session.results = Task {
            do {
                for try await result in transcriber.results {
                    onText(String(result.text.characters))
                }
                onEnd(nil)
            } catch {
                onEnd(error)
            }
        }
        return session
    }

    /// Adds microphone audio, converted to the format the model wants. Safe from the audio thread.
    func append(_ buffer: AVAudioPCMBuffer) {
        guard let converted = convert(buffer) else { return }
        input.yield(AnalyzerInput(buffer: converted))
    }

    /// No more audio: transcribes what is left, then returns.
    func finish() async {
        input.finish()
        try? await analyzer.finalizeAndFinishThroughEndOfInput()
        await results?.value
    }

    /// Stops at once and drops what is left.
    func cancel() {
        input.finish()
        results?.cancel()
        let analyzer = analyzer
        Task { await analyzer.cancelAndFinishNow() }
    }

    private func convert(_ buffer: AVAudioPCMBuffer) -> AVAudioPCMBuffer? {
        if buffer.format == format { return buffer }
        if converter == nil || converter?.inputFormat != buffer.format {
            converter = AVAudioConverter(from: buffer.format, to: format)
            // Live audio arrives in pieces; priming each piece would add or drop frames.
            converter?.primeMethod = .none
        }
        guard let converter else { return nil }
        let ratio = format.sampleRate / buffer.format.sampleRate
        let capacity = AVAudioFrameCount((Double(buffer.frameLength) * ratio).rounded(.up)) + 16
        guard let output = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: capacity) else { return nil }
        var given = false
        var error: NSError?
        converter.convert(to: output, error: &error) { _, status in
            if given {
                status.pointee = .noDataNow
                return nil
            }
            given = true
            status.pointee = .haveData
            return buffer
        }
        return error == nil && output.frameLength > 0 ? output : nil
    }
}

enum DictationError: Error {
    case noLocale
    case noFormat
}
#endif
