import XCTest

/// Runs Apple's accessibility audit (contrast, hit regions, labels, Dynamic Type, clipped
/// text, traits) on each screen in the real app. Issues fail the test with their description.
final class AccessibilityAuditUITests: XCTestCase {
    private var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = true
        app = XCUIApplication()
        app.launchArguments = ["-SelvoResetProfile", "-SelvoDemoProfile", "YES"]
        app.launch()
        XCTAssertTrue(app.buttons["Speak"].firstMatch.waitForExistence(timeout: 20))
    }

    private func audit(_ screen: String) throws {
        try app.performAccessibilityAudit { issue in
            let element = issue.element.map { "\($0.elementType.rawValue) '\($0.label)'" } ?? "no element"
            print("AUDIT \(screen): \(issue.auditType) \(issue.compactDescription) [\(element)]")
            return false
        }
    }

    private func tap(_ label: String) {
        let button = app.buttons[label].firstMatch
        XCTAssertTrue(button.waitForExistence(timeout: 10), "\(label) not found")
        button.tap()
    }

    func testHome() throws {
        try audit("Home")
    }

    func testPhotosAndSuggest() throws {
        tap("Photos")
        try audit("Photos")
        tap("Coffee")
        XCTAssertTrue(app.buttons["Another"].waitForExistence(timeout: 10))
        try audit("Suggest")
        tap("Show")
        XCTAssertTrue(app.buttons["Done"].waitForExistence(timeout: 5))
        try audit("Show")
    }

    func testHelp() throws {
        tap("Help")
        XCTAssertTrue(app.buttons["Yes, show it"].waitForExistence(timeout: 5))
        try audit("Help confirm")
        tap("Yes, show it")
        XCTAssertTrue(app.buttons["Done"].waitForExistence(timeout: 5))
        try audit("Help attention")
    }

    func testSettings() throws {
        tap("Settings")
        XCTAssertTrue(app.buttons["Back"].waitForExistence(timeout: 5))
        try audit("Settings")
    }
}
