import XCTest

extension XCUIElement {
    /// Taps a text field and types only once it has keyboard focus. On a slow Simulator the
    /// first tap can land before the field is ready, which made typeText fail now and then.
    func tapAndType(_ text: String, file: StaticString = #filePath, line: UInt = #line) {
        let focused = NSPredicate(format: "hasKeyboardFocus == true")
        for _ in 1...3 {
            tap()
            let wait = XCTNSPredicateExpectation(predicate: focused, object: self)
            if XCTWaiter.wait(for: [wait], timeout: 5) == .completed {
                typeText(text)
                return
            }
        }
        XCTFail("Text field never took keyboard focus", file: file, line: line)
    }
}
