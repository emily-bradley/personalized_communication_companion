import XCTest

extension XCUIElement {
    /// Taps a text field and types only once it has keyboard focus. On a slow Simulator the
    /// first tap can land before the field is ready, which made typeText fail now and then.
    /// Each try waits for the field to be hittable, so a tap never lands mid transition.
    func tapAndType(_ text: String, file: StaticString = #filePath, line: UInt = #line) {
        let hittable = NSPredicate(format: "isHittable == true")
        let focused = NSPredicate(format: "hasKeyboardFocus == true")
        for _ in 1...4 {
            _ = XCTWaiter.wait(for: [XCTNSPredicateExpectation(predicate: hittable, object: self)], timeout: 10)
            tap()
            let wait = XCTNSPredicateExpectation(predicate: focused, object: self)
            if XCTWaiter.wait(for: [wait], timeout: 10) == .completed {
                typeText(text)
                return
            }
        }
        XCTFail("Text field never took keyboard focus", file: file, line: line)
    }
}
