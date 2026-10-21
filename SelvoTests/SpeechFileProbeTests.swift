import AVFoundation
import Speech
import XCTest

/// Not a pass or fail test: it reports, in the test log, whether this Simulator can turn a
/// spoken sentence into text on the phone itself. It speaks a fixed test sentence into a file
/// with the system voice (never a person), then gives that file to the older on-device
/// recognizer and, on iOS 26 and later, to the newer DictationTranscriber. Lines start with
/// SPEECHPROBE. This tells us whether Listen fails in the iOS 27 Simulator because of the
/// recognizer itself or because of the live microphone path.
final class SpeechFileProbeTests: XCTestCase {
    private let sentence = "I would like a coffee please"

    func testReportRecognitionOfASpokenFile() async throws {
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("speech-probe.caf")
        let writer = SpokenFileWriter(url: url)
        do {
            try await withDeadline(45) { try await writer.write(self.sentence) }
        } catch {
            print("SPEECHPROBE writing the file ended: \(Self.describe(error))")
        }
        print("SPEECHPROBE file frames: \(writer.frames), sample rate \(writer.sampleRate)")
        guard writer.frames > 0 else { return }

        let status = SFSpeechRecognizer.authorizationStatus()
        print("SPEECHPROBE speech authorization: \(status.rawValue) (3 is authorized)")
        if status == .authorized, let recognizer = SFSpeechRecognizer() {
            print("SPEECHPROBE older recognizer on device: \(recognizer.supportsOnDeviceRecognition)")
            let request = SFSpeechURLRecognitionRequest(url: url)
            request.requiresOnDeviceRecognition = true
            do {
                let text = try await withDeadline(60) { try await Self.recognize(recognizer, request) }
                print("SPEECHPROBE older recognizer on device heard the test sentence: \(text)")
            } catch {
                print("SPEECHPROBE older recognizer on device failed: \(Self.describe(error))")
            }
        }

        #if compiler(>=6.2)
        if #available(iOS 26.0, *) {
            await probeDictationTranscriber(url)
        }
        #endif
    }

    #if compiler(>=6.2)
    @available(iOS 26.0, *)
    private func probeDictationTranscriber(_ url: URL) async {
        guard let locale = await DictationTranscriber.supportedLocale(equivalentTo: Locale(identifier: "en-US")) else {
            print("SPEECHPROBE dictation: no locale for en-US")
            return
        }
        do {
            let reserved = try await AssetInventory.reserve(locale: locale)
            print("SPEECHPROBE dictation reserve \(locale.identifier): \(reserved)")
        } catch {
            print("SPEECHPROBE dictation reserve failed: \(Self.describe(error))")
        }
        let transcriber = DictationTranscriber(locale: locale, preset: .longDictation)
        print("SPEECHPROBE dictation asset status before: \(await AssetInventory.status(forModules: [transcriber]))")
        do {
            try await withDeadline(240) {
                if let request = try await AssetInventory.assetInstallationRequest(supporting: [transcriber]) {
                    try await request.downloadAndInstall()
                    print("SPEECHPROBE dictation assets installed")
                } else {
                    print("SPEECHPROBE dictation no install needed")
                }
            }
        } catch {
            print("SPEECHPROBE dictation install failed: \(Self.describe(error))")
        }
        print("SPEECHPROBE dictation asset status after: \(await AssetInventory.status(forModules: [transcriber]))")
        do {
            let text = try await withDeadline(90) {
                let analyzer = SpeechAnalyzer(modules: [transcriber])
                let collected = Task { () -> String in
                    var heard = ""
                    for try await result in transcriber.results {
                        heard += String(result.text.characters)
                    }
                    return heard
                }
                let file = try AVAudioFile(forReading: url)
                if let end = try await analyzer.analyzeSequence(from: file) {
                    try await analyzer.finalizeAndFinish(through: end)
                } else {
                    await analyzer.cancelAndFinishNow()
                }
                return try await collected.value
            }
            print("SPEECHPROBE dictation heard the test sentence: \(text)")
        } catch {
            print("SPEECHPROBE dictation failed: \(Self.describe(error))")
        }
    }
    #endif

    private static func recognize(_ recognizer: SFSpeechRecognizer, _ request: SFSpeechURLRecognitionRequest) async throws -> String {
        let once = Once()
        return try await withCheckedThrowingContinuation { continuation in
            _ = recognizer.recognitionTask(with: request) { result, error in
                if let error {
                    once.run { continuation.resume(throwing: error) }
                } else if let result, result.isFinal {
                    once.run { continuation.resume(returning: result.bestTranscription.formattedString) }
                }
            }
        }
    }

    private static func describe(_ error: Error) -> String {
        let ns = error as NSError
        return "\(ns.domain) \(ns.code) \(ns.localizedDescription)"
    }
}

/// Speaks a sentence with the system voice into an audio file.
private final class SpokenFileWriter {
    let url: URL
    private(set) var frames: AVAudioFrameCount = 0
    private(set) var sampleRate: Double = 0
    private let synthesizer = AVSpeechSynthesizer()
    private var file: AVAudioFile?

    init(url: URL) {
        self.url = url
    }

    func write(_ text: String) async throws {
        try? FileManager.default.removeItem(at: url)
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        let once = Once()
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            synthesizer.write(utterance) { [self] buffer in
                guard let pcm = buffer as? AVAudioPCMBuffer else { return }
                if pcm.frameLength == 0 {
                    file = nil
                    once.run { continuation.resume() }
                    return
                }
                do {
                    if file == nil {
                        file = try AVAudioFile(forWriting: url, settings: pcm.format.settings,
                                               commonFormat: pcm.format.commonFormat,
                                               interleaved: pcm.format.isInterleaved)
                        sampleRate = pcm.format.sampleRate
                    }
                    try file?.write(from: pcm)
                    frames += pcm.frameLength
                } catch {
                    once.run { continuation.resume(throwing: error) }
                }
            }
        }
        file = nil
    }
}

/// Runs a closure at most once, from any thread.
private final class Once {
    private let lock = NSLock()
    private var done = false

    func run(_ body: () -> Void) {
        lock.lock()
        let first = !done
        done = true
        lock.unlock()
        if first { body() }
    }
}

private struct ProbeTimedOut: Error {}

/// Waits for `operation` at most `seconds`, so a probe never hangs the test run.
private func withDeadline<T>(_ seconds: Double, _ operation: @escaping () async throws -> T) async throws -> T {
    let once = Once()
    return try await withCheckedThrowingContinuation { continuation in
        Task {
            do {
                let value = try await operation()
                once.run { continuation.resume(returning: value) }
            } catch {
                once.run { continuation.resume(throwing: error) }
            }
        }
        Task {
            try? await Task.sleep(nanoseconds: UInt64(seconds * 1_000_000_000))
            once.run { continuation.resume(throwing: ProbeTimedOut()) }
        }
    }
}
