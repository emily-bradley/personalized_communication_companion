import SwiftUI
import UIKit
import XCTest
import SelvoCore
@testable import Selvo

/// Measures the real components and checks the touch target rules from the brand book.
@MainActor
final class ComponentSizingTests: XCTestCase {
    private func size<V: View>(_ view: V, width: CGFloat = 358) -> CGSize {
        let host = UIHostingController(rootView: view.environment(\.theme, .night))
        return host.sizeThatFits(in: CGSize(width: width, height: .greatestFiniteMagnitude))
    }

    func testSpeakIsSixtyFourTallAndFullWidth() {
        let s = size(PrimaryButton(title: "Speak") {})
        XCTAssertGreaterThanOrEqual(s.height, 64)
        XCTAssertEqual(s.width, 358, accuracy: 0.5)
    }

    func testQuietButtonMeetsTouchFloor() {
        XCTAssertGreaterThanOrEqual(size(QuietButton(title: "Another") {}).height, 44)
    }

    func testTopBarControlsMeetTouchFloor() {
        XCTAssertGreaterThanOrEqual(size(BackButton {}).height, 44)
        let help = size(HelpButton {})
        XCTAssertGreaterThanOrEqual(help.height, 44)
        XCTAssertGreaterThanOrEqual(help.width, 44)
        let gear = size(IconButton(systemImage: "gearshape", label: "Settings") {})
        XCTAssertGreaterThanOrEqual(gear.width, 44)
        XCTAssertGreaterThanOrEqual(gear.height, 44)
        XCTAssertGreaterThanOrEqual(size(LinkButton(title: "Show", action: {}) { ShowGlyph() }).height, 44)
    }

    func testTileIsAtLeastNinetySix() {
        let s = size(Tile(label: "Coffee", artwork: .symbol("cup.and.saucer")) {}.fixedSize(), width: 400)
        XCTAssertGreaterThanOrEqual(s.width, 96)
        XCTAssertGreaterThanOrEqual(s.height, 96)
    }

    func testMessageStripMinimumHeight() {
        XCTAssertGreaterThanOrEqual(size(MessageStrip(message: nil)).height, 72)
    }

    /// Suggest keeps two lines, so the cards do not move when the message wraps.
    func testMessageStripKeepsReservedLines() {
        let short = size(MessageStrip(message: "Coffee. Now. Please.", reservedLines: 2)).height
        let wrapped = size(MessageStrip(message: "Coffee first. Then I'll be nice.", reservedLines: 2)).height
        XCTAssertEqual(short, wrapped, accuracy: 0.5)
        XCTAssertGreaterThan(short, size(MessageStrip(message: "Coffee. Now. Please.")).height)
    }

    func testSuggestionCardMeetsTouchFloor() {
        XCTAssertGreaterThanOrEqual(size(SuggestionCard(text: "Yes", caption: nil) {}).height, 44)
    }

    func testBundledFontsAreRegistered() {
        for font in ReadingFont.allCases {
            for semibold in [false, true] {
                let name = font.postScriptName(semibold: semibold)
                XCTAssertNotNil(UIFont(name: name, size: 17), "\(name) is not registered")
            }
        }
    }
}
