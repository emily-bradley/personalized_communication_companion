import Foundation
import XCTest
@testable import SelvoCore

private func card(_ text: String, _ style: SuggestionStyle = .plain) -> Suggestion {
    Suggestion(text: text, style: style, source: .savedPhrase)
}

private func coffeeContext() -> SuggestionContext {
    SuggestionContext(personName: "Lucas", tileLabel: "Coffee", category: .photos)
}

private let artboardCoffee = [
    "Can we get coffee before work?",
    "Coffee first. Then I'll be nice.",
    "Is there time for coffee?",
]

final class SuggestionStackTests: XCTestCase {
    private func abc() -> SuggestionStack {
        var stack = SuggestionStack()
        stack.replaceAll(with: [card("A"), card("B"), card("C")])
        return stack
    }

    func testShowsThreeAtATime() {
        var stack = SuggestionStack()
        XCTAssertEqual(SuggestionStack.size, 3)
        XCTAssertNil(stack.selectedIndex)
        stack.replaceAll(with: [card("A"), card("B"), card("C"), card("D"), card("E")])
        XCTAssertEqual(stack.cards.map { $0.text }, ["A", "B", "C"])
        XCTAssertEqual(stack.selectedIndex, 0)
        XCTAssertEqual(stack.shown, ["A", "B", "C"])
        XCTAssertFalse(stack.needsFill)
    }

    func testAnotherReplacesAllThreeAndNeverRepeatsWhilePhrasesRemain() {
        let provider = SavedPhraseProvider()
        var stack = SuggestionStack()
        stack.replaceAll(with: provider.phrases(for: coffeeContext(), count: 3, excluding: stack.excluded))
        let first = stack.cards.map { $0.text }

        stack.replaceAll(with: provider.phrases(for: coffeeContext(), count: 3, excluding: stack.excluded))
        let second = stack.cards.map { $0.text }

        XCTAssertEqual(second.count, 3)
        XCTAssertTrue(Set(first).isDisjoint(with: Set(second)))
        XCTAssertEqual(stack.shown.count, 6)
        XCTAssertEqual(stack.selectedIndex, 0)
    }

    func testIncorrectRemovesOneLogsItAndRefillKeepsTheOthers() {
        var stack = abc()
        stack.markIncorrect(at: 1)
        XCTAssertEqual(stack.cards.map { $0.text }, ["A", "C"])
        XCTAssertEqual(stack.incorrect.map { $0.text }, ["B"])
        XCTAssertTrue(stack.excluded.contains("B"))
        XCTAssertTrue(stack.needsFill)

        stack.fill(with: [card("A"), card("D"), card("E")])
        XCTAssertEqual(stack.cards.map { $0.text }, ["A", "C", "D"])
        XCTAssertEqual(stack.incorrect.count, 1)
        XCTAssertTrue(stack.shown.contains("D"))
        XCTAssertFalse(stack.shown.contains("E"))
    }

    func testUndoRestoresPreviousStack() {
        var stack = abc()
        stack.replaceAll(with: [card("D"), card("E"), card("F")])
        XCTAssertTrue(stack.canUndo)
        XCTAssertTrue(stack.undo())
        XCTAssertEqual(stack.cards.map { $0.text }, ["A", "B", "C"])
    }

    func testUndoAfterIncorrectAndFillBringsBackTheOriginalThree() {
        var stack = abc()
        stack.select(2)
        stack.markIncorrect(at: 0)
        stack.fill(with: [card("D")])
        XCTAssertEqual(stack.cards.map { $0.text }, ["B", "C", "D"])

        stack.undo()
        XCTAssertEqual(stack.cards.map { $0.text }, ["A", "B", "C"])
        XCTAssertTrue(stack.incorrect.isEmpty)
        XCTAssertEqual(stack.selected?.text, "C")
    }

    func testUndoWithNothingToUndo() {
        var stack = SuggestionStack()
        XCTAssertFalse(stack.canUndo)
        XCTAssertFalse(stack.undo())
    }

    func testSelectionRules() {
        var stack = abc()
        XCTAssertEqual(stack.selected?.text, "A")

        stack.select(2)
        XCTAssertEqual(stack.selected?.text, "C")
        stack.select(7)
        XCTAssertEqual(stack.selectedIndex, 2)

        // Removing the selected last card selects the new last card.
        stack.markIncorrect(at: 2)
        XCTAssertEqual(stack.selected?.text, "B")

        // Removing a card before the selection keeps the same card selected.
        stack.markIncorrect(at: 0)
        XCTAssertEqual(stack.selected?.text, "B")
        XCTAssertEqual(stack.selectedIndex, 0)

        stack.markIncorrect(at: 0)
        XCTAssertNil(stack.selected)
        XCTAssertNil(stack.selectedIndex)

        stack.fill(with: [card("D")])
        XCTAssertEqual(stack.selected?.text, "D")
    }

    func testSelectingIsUndoable() {
        var stack = abc()
        stack.select(1)
        stack.undo()
        XCTAssertEqual(stack.selectedIndex, 0)
    }
}

final class SavedPhraseProviderTests: XCTestCase {
    private let provider = SavedPhraseProvider()

    func testCoversEveryDemoTileLabel() {
        let profile = DemoProfile.lucas
        for tile in profile.tiles {
            XCTAssertTrue(SavedPhraseProvider.hasTemplates(forLabel: tile.label), tile.label)
            let context = SuggestionContext(profile: profile, tile: tile)
            let texts = provider.phrases(for: context, count: 6, excluding: []).map { $0.text }
            XCTAssertEqual(Set(texts).count, 6, tile.label)
            for style in SuggestionStyle.allCases {
                XCTAssertGreaterThanOrEqual(provider.templates(for: context).phrases(style).count, 2, tile.label)
            }
        }
    }

    func testCoffeeStartsWithTheArtboardPhrasesInStyleOrder() {
        let result = provider.phrases(for: coffeeContext(), count: 3, excluding: [])
        XCTAssertEqual(result.map { $0.text }, artboardCoffee)
        XCTAssertEqual(result.map { $0.style }, [.plain, .witty, .short])
        XCTAssertTrue(result.allSatisfy { $0.source == .savedPhrase })
    }

    func testCoffeeIncludesTheAlternates() {
        let all = Set(provider.phrases(for: coffeeContext(), count: 20, excluding: []).map { $0.text })
        for text in ["Coffee. Now. Please.", "Do we have time to stop for coffee?", "I could use a coffee before we go."] {
            XCTAssertTrue(all.contains(text), text)
        }
    }

    func testCoffeeAnotherGivesTheArtboardAlternates() {
        let first = provider.phrases(for: coffeeContext(), count: 3, excluding: [])
        let second = provider.phrases(for: coffeeContext(), count: 3, excluding: Set(first.map { $0.text }))
        XCTAssertEqual(second.map { $0.text }, [
            "Do we have time to stop for coffee?",
            "Coffee. Now. Please.",
            "I could use a coffee before we go.",
        ])
        XCTAssertEqual(second.map { $0.style }, [.plain, .witty, .short])
    }

    func testLabelsMatchIgnoringCase() {
        let context = SuggestionContext(personName: "Lucas", tileLabel: "  cOFFEE ")
        XCTAssertEqual(provider.phrases(for: context, count: 3, excluding: []).map { $0.text }, artboardCoffee)
    }

    func testRespectsExclusionsAndReturnsWhatRemains() {
        let all = provider.phrases(for: coffeeContext(), count: 20, excluding: []).map { $0.text }
        XCTAssertEqual(all.count, 7)
        let remaining = provider.phrases(for: coffeeContext(), count: 3, excluding: Set(all.dropLast()))
        XCTAssertEqual(remaining.map { $0.text }, [all[all.count - 1]])
        XCTAssertTrue(provider.phrases(for: coffeeContext(), count: 3, excluding: Set(all)).isEmpty)
    }

    func testRequestedStylesOnly() {
        var context = coffeeContext()
        context.styles = [.witty]
        let result = provider.phrases(for: context, count: 5, excluding: [])
        XCTAssertEqual(result.map { $0.text }, ["Coffee first. Then I'll be nice.", "Coffee. Now. Please."])
    }

    func testUnknownLabelUsesTheLabel() {
        let context = SuggestionContext(personName: "Lucas", tileLabel: "Grandma")
        XCTAssertFalse(SavedPhraseProvider.hasTemplates(forLabel: "Grandma"))
        let result = provider.phrases(for: context, count: 3, excluding: [])
        XCTAssertEqual(result.count, 3)
        XCTAssertTrue(result.allSatisfy { $0.text.contains("Grandma") })
    }

    func testHeardTextGivesReplies() {
        let context = SuggestionContext(personName: "Lucas", heardText: "Do you want to go out tonight?")
        let texts = provider.phrases(for: context, count: 9, excluding: []).map { $0.text }
        XCTAssertEqual(texts.first, "Yes, I'd like that.")
        XCTAssertTrue(texts.contains("Not today."))
        XCTAssertTrue(texts.contains("Let me think about it."))
    }

    func testNoContextStillOffersThree() {
        let context = SuggestionContext(personName: "Lucas")
        XCTAssertEqual(provider.phrases(for: context, count: 3, excluding: []).count, 3)
    }

    func testCaption() {
        let suggestion = card("Coffee first. Then I'll be nice.", .witty)
        XCTAssertEqual(suggestion.caption(personName: "Lucas"), "Suggested for Lucas \u{00B7} witty")
    }

    func testSavedPhrasesAvoidBannedPunctuation() {
        let profile = DemoProfile.lucas
        for tile in profile.tiles {
            let context = SuggestionContext(profile: profile, tile: tile)
            for text in provider.phrases(for: context, count: 20, excluding: []).map({ $0.text }) {
                XCTAssertFalse(text.contains("!"), text)
                XCTAssertFalse(text.contains("\u{2014}"), text)
                XCTAssertFalse(text.contains("\u{2013}"), text)
            }
        }
    }
}

private struct FixedProvider: SuggestionProvider {
    let texts: [String]

    func suggestions(for context: SuggestionContext, count: Int, excluding: Set<String>) async -> [Suggestion] {
        texts.filter { !excluding.contains($0) }.prefix(count).map {
            Suggestion(text: $0, style: .plain, source: .model)
        }
    }
}

private struct SlowProvider: SuggestionProvider {
    func suggestions(for context: SuggestionContext, count: Int, excluding: Set<String>) async -> [Suggestion] {
        try? await Task.sleep(nanoseconds: 5_000_000_000)
        return [Suggestion(text: "Too late", style: .plain, source: .model)]
    }
}

final class SuggestionEngineTests: XCTestCase {
    func testFallsBackWhenThereIsNoPrimary() async throws {
        let engine = SuggestionEngine()
        let result = await engine.firstStack(for: coffeeContext())
        XCTAssertTrue(result.usedFallback)
        XCTAssertEqual(result.suggestions.map { $0.text }, artboardCoffee)
    }

    func testFallsBackWhenThePrimaryIsSlow() async throws {
        let engine = SuggestionEngine(primary: SlowProvider(), timeout: 0.1)
        let start = Date()
        let result = await engine.firstStack(for: coffeeContext())
        XCTAssertLessThan(Date().timeIntervalSince(start), 3)
        XCTAssertTrue(result.usedFallback)
        XCTAssertEqual(result.suggestions.map { $0.text }, artboardCoffee)
    }

    func testFallsBackWhenThePrimaryReturnsNothing() async throws {
        let engine = SuggestionEngine(primary: FixedProvider(texts: []), timeout: 1)
        let result = await engine.firstStack(for: coffeeContext())
        XCTAssertTrue(result.usedFallback)
        XCTAssertEqual(result.suggestions.map { $0.text }, artboardCoffee)
    }

    func testUsesThePrimaryWhenItAnswersInTime() async throws {
        let engine = SuggestionEngine(primary: FixedProvider(texts: ["One", "Two", "Three", "Four"]), timeout: 1)
        let result = await engine.firstStack(for: coffeeContext())
        XCTAssertFalse(result.usedFallback)
        XCTAssertEqual(result.suggestions.map { $0.text }, ["One", "Two", "Three"])
        XCTAssertTrue(result.suggestions.allSatisfy { $0.source == .model })
    }

    func testTopsUpTooFewWithSavedPhrases() async throws {
        let engine = SuggestionEngine(primary: FixedProvider(texts: ["One"]), timeout: 1)
        let result = await engine.next(for: coffeeContext(), count: 3, excluding: [])
        XCTAssertTrue(result.usedFallback)
        XCTAssertEqual(result.suggestions.map { $0.text }, ["One", artboardCoffee[0], artboardCoffee[1]])
    }

    func testEngineRespectsExclusions() async throws {
        let engine = SuggestionEngine(primary: FixedProvider(texts: ["One", "Two"]), timeout: 1)
        let result = await engine.next(for: coffeeContext(), count: 1, excluding: ["One"])
        XCTAssertFalse(result.usedFallback)
        XCTAssertEqual(result.suggestions.map { $0.text }, ["Two"])
    }
}
