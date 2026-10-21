import XCTest
import Speech

/// Not a pass or fail test: it reports, in the test log, whether the iOS 26 and later on-device
/// transcriber (SpeechAnalyzer) can run in this Simulator. On the iOS 27 Simulator the older
/// on-device recognizer fails to start (kLSRErrorDomain 300), so this tells us whether the newer
/// API is a way to keep Listen fully on the phone there. Lines start with SPEECHPROBE.
final class SpeechProbeTests: XCTestCase {
    func testReportOnDeviceTranscriberAvailability() async throws {
        #if compiler(>=6.2)
        if #available(iOS 26.0, *) {
            print("SPEECHPROBE transcriber available: \(SpeechTranscriber.isAvailable)")
            let dictation = await DictationTranscriber.supportedLocale(equivalentTo: Locale(identifier: "en-US"))
            print("SPEECHPROBE dictation transcriber locale: \(dictation?.identifier ?? "none")")
            print("SPEECHPROBE older recognizer on device: \(SFSpeechRecognizer()?.supportsOnDeviceRecognition ?? false)")
            guard let locale = await SpeechTranscriber.supportedLocale(equivalentTo: Locale(identifier: "en-US")) else {
                print("SPEECHPROBE no supported locale for en-US")
                return
            }
            print("SPEECHPROBE locale \(locale.identifier)")
            let transcriber = SpeechTranscriber(
                locale: locale,
                transcriptionOptions: [],
                reportingOptions: [.volatileResults],
                attributeOptions: []
            )
            let before = await AssetInventory.status(forModules: [transcriber])
            print("SPEECHPROBE asset status before: \(before)")
            do {
                if let request = try await AssetInventory.assetInstallationRequest(supporting: [transcriber]) {
                    try await request.downloadAndInstall()
                    print("SPEECHPROBE assets installed")
                } else {
                    print("SPEECHPROBE no install needed")
                }
            } catch {
                print("SPEECHPROBE install failed: \(error)")
            }
            let after = await AssetInventory.status(forModules: [transcriber])
            print("SPEECHPROBE asset status after: \(after)")
        } else {
            print("SPEECHPROBE iOS older than 26")
        }
        #else
        print("SPEECHPROBE SDK older than iOS 26")
        #endif
    }
}
