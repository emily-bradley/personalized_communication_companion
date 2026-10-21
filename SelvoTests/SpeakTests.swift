import XCTest
import SelvoCore
@testable import Selvo

/// A quick double tap on Speak says the message once, with one haptic.
@MainActor
final class SpeakTests: XCTestCase {
    private func model() -> AppModel {
        let model = AppModel.preview()
        model.message = "Can I have a coffee, please?"
        return model
    }

    func testSecondSpeakWhileTheSameMessagePlaysIsIgnored() {
        let model = model()
        model.speak()
        let first = model.lastSpokenAt
        XCTAssertNotNil(first)
        XCTAssertTrue(model.speech.isSpeaking)
        model.speak()
        XCTAssertEqual(model.lastSpokenAt, first)
        model.speech.stop()
    }

    func testANewMessageIsSpokenRightAway() {
        let model = model()
        model.speak()
        let first = model.lastSpokenAt
        model.message = "Not now, thank you."
        model.speak()
        XCTAssertNotEqual(model.lastSpokenAt, first)
        model.speech.stop()
    }
}
