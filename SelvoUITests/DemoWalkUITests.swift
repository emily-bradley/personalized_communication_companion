import XCTest

/// Walks the parts of the demo script (docs/DEMO.md) that CoreFlowUITests does not: Welcome,
/// setup together, Incorrect and Undo, Listen, and the Settings theme and reading font.
/// Saves real screenshots to $SCREENSHOT_DIR with the prefix "ui-".
final class DemoWalkUITests: XCTestCase {
    private var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
    }

    private func launch(demoProfile: Bool) {
        app.launchArguments = ["-SelvoResetProfile", "-SelvoDemoProfile", demoProfile ? "YES" : "NO"]
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

    private func tap(_ label: String, file: StaticString = #filePath, line: UInt = #line) {
        let button = app.buttons[label].firstMatch
        XCTAssertTrue(button.waitForExistence(timeout: 15), "\(label) not found", file: file, line: line)
        button.tap()
    }

    /// Taps a button on a screen that may scroll, swiping until it can be tapped.
    private func tapScrolling(_ label: String, file: StaticString = #filePath, line: UInt = #line) {
        let button = app.buttons[label].firstMatch
        XCTAssertTrue(button.waitForExistence(timeout: 15), "\(label) not found", file: file, line: line)
        for attempt in 0..<5 where !button.isHittable {
            if attempt < 2 { app.swipeUp() } else { app.swipeDown() }
        }
        button.tap()
    }

    private func buttonContaining(_ text: String) -> XCUIElement {
        app.buttons.matching(NSPredicate(format: "label CONTAINS %@", text)).firstMatch
    }

    private func wait(_ element: XCUIElement, until format: String, timeout: TimeInterval = 15) -> Bool {
        let expectation = XCTNSPredicateExpectation(predicate: NSPredicate(format: format), object: element)
        return XCTWaiter().wait(for: [expectation], timeout: timeout) == .completed
    }

    private func assertHome(file: StaticString = #filePath, line: UInt = #line) {
        XCTAssertTrue(app.buttons["Speak"].firstMatch.waitForExistence(timeout: 20), "Home shows Speak", file: file, line: line)
    }

    // MARK: Welcome

    func testWelcomeExistingProfile() throws {
        launch(demoProfile: false)
        XCTAssertTrue(app.staticTexts["Your voice. Your way."].waitForExistence(timeout: 20), "Welcome shows the tagline")
        XCTAssertTrue(app.buttons["Set up together"].exists)
        XCTAssertTrue(app.buttons["I already have a profile"].exists)
        save("demo-01-welcome")
        tap("I already have a profile")
        assertHome()
        let greeting = app.staticTexts.matching(NSPredicate(format: "label CONTAINS %@", "Lucas. Where would you like to start?")).firstMatch
        XCTAssertTrue(greeting.waitForExistence(timeout: 10), "Home greets Lucas")
    }

    // MARK: Setup

    func testSetupTogetherFinishesAtHome() throws {
        launch(demoProfile: false)
        tap("Set up together")

        XCTAssertTrue(app.staticTexts["What should Selvo call you?"].waitForExistence(timeout: 15))
        XCTAssertTrue(app.staticTexts["Step 1 of 5"].exists)
        let name = app.textFields["Name"].firstMatch
        XCTAssertTrue(name.waitForExistence(timeout: 10))
        name.tap()
        name.typeText("Maya")
        save("demo-setup-1")
        tap("Continue")

        XCTAssertTrue(app.staticTexts["Who does Maya talk to most?"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.staticTexts["Step 2 of 5"].exists)
        save("demo-setup-2")
        tap("Continue")

        XCTAssertTrue(app.staticTexts["Where does Maya go?"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.staticTexts["Step 3 of 5"].exists)
        save("demo-setup-3")
        tap("Continue")

        XCTAssertTrue(app.staticTexts["How should Selvo look?"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.staticTexts["Step 4 of 5"].exists)
        save("demo-setup-4")
        tap("Continue")

        XCTAssertTrue(app.staticTexts["How should Selvo sound?"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.staticTexts["Step 5 of 5"].exists)
        save("demo-setup-5")
        tap("Finish")

        assertHome()
        let greeting = app.staticTexts.matching(NSPredicate(format: "label CONTAINS %@", "Maya. Where would you like to start?")).firstMatch
        XCTAssertTrue(greeting.waitForExistence(timeout: 10), "Home greets the name from setup")
    }

    // MARK: Incorrect and Undo

    func testIncorrectAndUndo() throws {
        launch(demoProfile: true)
        assertHome()
        tap("Photos")
        tap("Coffee")

        // Saved phrases for Coffee, in Lucas's styles (plain, witty, short).
        let witty = buttonContaining("Coffee first. Then I'll be nice.")
        XCTAssertTrue(witty.waitForExistence(timeout: 15), "three saved phrase suggestions appear")
        let cards = app.buttons.matching(NSPredicate(format: "label CONTAINS %@", "Suggested for Lucas"))
        XCTAssertEqual(cards.count, 3, "three suggestions")
        witty.tap()
        XCTAssertTrue(wait(witty, until: "isSelected == true"), "the witty suggestion is selected")

        tap("Incorrect")
        XCTAssertTrue(wait(witty, until: "exists == false"), "Incorrect removes the selected suggestion")
        XCTAssertEqual(cards.count, 3, "a new suggestion takes its place")
        save("demo-04-incorrect")

        let undo = app.buttons["Undo"].firstMatch
        XCTAssertTrue(wait(undo, until: "isEnabled == true"), "Undo is ready")
        undo.tap()
        XCTAssertTrue(witty.waitForExistence(timeout: 10), "Undo brings the suggestion back")
        XCTAssertEqual(cards.count, 3)
        save("demo-05-undo")
    }

    // MARK: Listen

    func testListenShowsListeningAndStops() throws {
        launch(demoProfile: true)
        addUIInterruptionMonitor(withDescription: "Microphone and speech recognition") { alert in
            for label in ["Allow", "OK"] where alert.buttons[label].exists {
                alert.buttons[label].tap()
                return true
            }
            return false
        }
        assertHome()
        tap("Listen")
        XCTAssertTrue(app.staticTexts["Listen"].waitForExistence(timeout: 15), "the Listen screen opens")

        // Any interaction lets the monitor answer the permission alerts, one at a time.
        for _ in 1...2 {
            app.swipeUp()
            Thread.sleep(forTimeInterval: 1)
        }

        // Speech recognition may be unavailable or denied in a CI Simulator, so any status counts.
        let statuses = [
            "Listening",
            "Getting ready to listen",
            "Not listening",
            "Listening is not available on this phone right now.",
            "Selvo needs speech recognition to show what people say to you. You can turn it on in Settings.",
            "Selvo needs the microphone to show what people say to you. You can turn it on in Settings.",
        ]
        XCTAssertNotNil(firstExisting(statuses.map { app.staticTexts[$0] }, timeout: 20), "Listen shows whether it is listening")
        let stop = app.buttons["Stop listening"].firstMatch
        let done = app.buttons["Done"].firstMatch
        XCTAssertNotNil(firstExisting([stop, done], timeout: 10), "Stop listening, or Done when listening cannot run")
        XCTAssertTrue(app.buttons["Back"].exists)
        save("demo-07-listen")

        if stop.exists {
            stop.tap()
        } else if done.exists {
            done.tap()
        } else {
            tap("Back")
        }
        assertHome()
    }

    private func firstExisting(_ elements: [XCUIElement], timeout: TimeInterval) -> XCUIElement? {
        let end = Date().addingTimeInterval(timeout)
        repeat {
            if let found = elements.first(where: { $0.exists }) { return found }
            RunLoop.current.run(until: Date().addingTimeInterval(0.5))
        } while Date() < end
        return nil
    }

    // MARK: Settings

    func testSettingsThemeAndFont() throws {
        launch(demoProfile: true)
        assertHome()
        tap("Settings")
        XCTAssertTrue(app.staticTexts["Theme"].waitForExistence(timeout: 15))

        tapScrolling("Daylight theme")
        let daylight = app.buttons["Daylight theme"].firstMatch
        XCTAssertTrue(wait(daylight, until: "isSelected == true"), "Daylight is selected")
        XCTAssertFalse(app.buttons["Nightlight theme"].firstMatch.isSelected)
        save("demo-09-settings-daylight")

        tapScrolling("Atkinson Hyperlegible font")
        XCTAssertTrue(wait(app.buttons["Atkinson Hyperlegible font"].firstMatch, until: "isSelected == true"), "Atkinson is selected")
        tapScrolling("Lexend font")
        XCTAssertTrue(wait(app.buttons["Lexend font"].firstMatch, until: "isSelected == true"), "Lexend is selected again")

        tapScrolling("Nightlight theme")
        XCTAssertTrue(wait(app.buttons["Nightlight theme"].firstMatch, until: "isSelected == true"), "Nightlight is selected again")
    }
}
