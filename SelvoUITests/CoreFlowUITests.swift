import XCTest

/// Drives the real app in the Simulator: Home to Spoken in two taps plus Speak, with saved
/// phrases only (no network), then Show, Listen, Help and Settings. Saves real screenshots to
/// $SCREENSHOT_DIR with the prefix "ui-".
final class CoreFlowUITests: XCTestCase {
    private var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["-SelvoResetProfile", "-SelvoDemoProfile", "YES"]
        app.launch()
    }

    private func save(_ name: String) {
        let shot = XCUIScreen.main.screenshot()
        let attachment = XCTAttachment(screenshot: shot)
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
        guard let dir = ProcessInfo.processInfo.environment["SCREENSHOT_DIR"] else { return }
        try? FileManager.default.createDirectory(atPath: dir, withIntermediateDirectories: true)
        try? shot.pngRepresentation.write(to: URL(fileURLWithPath: dir).appendingPathComponent("ui-\(name).png"))
    }

    private func element(_ label: String) -> XCUIElement {
        app.descendants(matching: .any)[label].firstMatch
    }

    private func tap(_ label: String, file: StaticString = #filePath, line: UInt = #line) {
        let button = app.buttons[label].firstMatch
        XCTAssertTrue(button.waitForExistence(timeout: 10), "\(label) not found", file: file, line: line)
        button.tap()
    }

    func testHomeToSpokenWithSavedPhrases() throws {
        let speak = app.buttons["Speak"].firstMatch
        XCTAssertTrue(speak.waitForExistence(timeout: 20), "Home opens with the demo profile")
        XCTAssertFalse(speak.isEnabled, "Speak is disabled while the strip is empty")
        save("01-home")

        tap("Photos")
        // Waits for the grid, so the picture shows Photos and not Home mid transition.
        XCTAssertTrue(app.buttons["Coffee"].waitForExistence(timeout: 10), "Photos opens")
        save("02-photos")
        tap("Coffee")

        let first = app.buttons.containing(NSPredicate(format: "label CONTAINS %@", "Can we get coffee before work?")).firstMatch
        XCTAssertTrue(first.waitForExistence(timeout: 10), "three saved phrase suggestions appear")
        XCTAssertTrue(app.buttons["Another"].exists)
        XCTAssertTrue(app.buttons["Incorrect"].exists)
        save("03-suggest")

        let witty = app.buttons.containing(NSPredicate(format: "label CONTAINS %@", "Coffee first. Then I'll be nice.")).firstMatch
        witty.tap()
        tap("Speak")
        XCTAssertTrue(element("Spoken").waitForExistence(timeout: 3), "Spoken shows after Speak")
        save("04-spoken")

        tap("Another")
        XCTAssertFalse(app.buttons.containing(NSPredicate(format: "label CONTAINS %@", "Can we get coffee before work?")).firstMatch.exists,
                       "Another replaces the whole stack")
        save("05-another")

        tap("Show")
        XCTAssertTrue(app.buttons["Done"].waitForExistence(timeout: 5))
        save("06-show")
        tap("Done")
    }

    func testHelpTakesTwoTaps() throws {
        tap("Help")
        XCTAssertTrue(app.buttons["Yes, show it"].waitForExistence(timeout: 5))
        save("07-help-confirm")
        tap("Yes, show it")
        XCTAssertTrue(element("I need help.").waitForExistence(timeout: 5))
        save("08-help-attention")
        tap("Done")
    }

    /// A supporter moves Coffee one place later in Edit Photos. The grid shows the new order,
    /// and it is still there after the app is closed and opened again.
    func testSupporterMovesTileLater() throws {
        tap("Settings")
        app.swipeUp()
        tap("Edit Photos")
        let coffee = app.buttons["Coffee"].firstMatch
        XCTAssertTrue(coffee.waitForExistence(timeout: 5))
        coffee.press(forDuration: 1.2)
        tap("Move later")
        XCTAssertTrue(app.buttons["Dinner"].firstMatch.frame.minY < app.buttons["Coffee"].firstMatch.frame.minY,
                      "Coffee is listed after Dinner")
        save("10-edit-photos-moved")
        tap("Back")
        tap("Back")
        assertCoffeeAfterDinnerOnGrid()

        app.terminate()
        app.launchArguments = ["-SelvoDemoProfile", "YES"]
        app.launch()
        assertCoffeeAfterDinnerOnGrid()
    }

    private func assertCoffeeAfterDinnerOnGrid(file: StaticString = #filePath, line: UInt = #line) {
        tap("Photos", file: file, line: line)
        let coffee = app.buttons["Coffee"].firstMatch
        let dinner = app.buttons["Dinner"].firstMatch
        XCTAssertTrue(coffee.waitForExistence(timeout: 10), file: file, line: line)
        XCTAssertEqual(coffee.frame.midY, dinner.frame.midY, accuracy: 2, "same row", file: file, line: line)
        XCTAssertGreaterThan(coffee.frame.minX, dinner.frame.minX, "Coffee is in the second slot", file: file, line: line)
    }

    /// Real screenshots at accessibility XL text, where content scrolls as it does in the app
    /// (the ImageRenderer screenshots can only show the top of scrolling content).
    func testAccessibilityXLScreens() throws {
        app.terminate()
        app.launchArguments += ["-UIPreferredContentSizeCategoryName", "UICTContentSizeCategoryAccessibilityXL"]
        app.launch()
        XCTAssertTrue(app.buttons["Speak"].firstMatch.waitForExistence(timeout: 20))
        save("axl-01-home")
        tap("Photos")
        XCTAssertTrue(app.buttons["Coffee"].waitForExistence(timeout: 10))
        save("axl-02-photos")
        tap("Coffee")
        XCTAssertTrue(app.buttons["Another"].waitForExistence(timeout: 10))
        save("axl-03-suggest")
        app.swipeUp()
        save("axl-03b-suggest-scrolled")
        tap("Back")
        tap("Back")
        tap("Settings")
        XCTAssertTrue(element("Text size").waitForExistence(timeout: 5))
        save("axl-09-settings")
        app.swipeUp()
        save("axl-09b-settings-scrolled")
        tap("Back")
        tap("Help")
        XCTAssertTrue(app.buttons["Yes, show it"].waitForExistence(timeout: 5))
        save("axl-07-help-confirm")
        tap("Yes, show it")
        XCTAssertTrue(element("I need help.").waitForExistence(timeout: 5))
        save("axl-08-help-attention")
    }

    func testSettingsOpens() throws {
        tap("Settings")
        XCTAssertTrue(element("Text size").waitForExistence(timeout: 5))
        save("09-settings")
    }
}
