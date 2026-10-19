import Foundation

/// The three suggestion cards on the Suggest screen and the rules around them.
///
/// Another replaces the whole stack. Incorrect removes one card and logs it; `fill(with:)` then
/// appends the next suggestion at the end so the other cards keep their order. Every change
/// except `fill(with:)` can be undone; a fill completes the change before it, so one Undo after
/// Incorrect brings back the original three.
public struct SuggestionStack: Equatable, Sendable {
    public static let size = 3

    private struct State: Equatable, Sendable {
        var cards: [Suggestion] = []
        var selectedIndex: Int?
        var shown: Set<String> = []
        var incorrect: [Suggestion] = []
    }

    private var state = State()
    private var history: [State] = []

    public init() {}

    /// The visible cards, never more than `size`.
    public var cards: [Suggestion] { state.cards }
    /// Index of the selected card. 0 whenever the stack has cards and nothing else was chosen.
    public var selectedIndex: Int? { state.selectedIndex }
    /// Every text that has been on screen in this stack.
    public var shown: Set<String> { state.shown }
    /// Cards marked Incorrect, oldest first. This is the feedback log for the model.
    public var incorrect: [Suggestion] { state.incorrect }

    public var selected: Suggestion? {
        guard let index = state.selectedIndex, state.cards.indices.contains(index) else { return nil }
        return state.cards[index]
    }

    /// Texts a provider should not offer again.
    public var excluded: Set<String> {
        state.shown.union(state.incorrect.map { $0.text })
    }

    /// True when a card is missing, for example right after Incorrect.
    public var needsFill: Bool { state.cards.count < Self.size }

    public var canUndo: Bool { !history.isEmpty }

    /// Another, or the first stack: replace every card.
    public mutating func replaceAll(with suggestions: [Suggestion]) {
        history.append(state)
        state.cards = Array(Self.unique(suggestions).prefix(Self.size))
        for card in state.cards { state.shown.insert(card.text) }
        state.selectedIndex = state.cards.isEmpty ? nil : 0
    }

    /// Incorrect: remove one card and log it. Call `fill(with:)` afterwards to top the stack up.
    public mutating func markIncorrect(at index: Int) {
        guard state.cards.indices.contains(index) else { return }
        history.append(state)
        let removed = state.cards.remove(at: index)
        state.incorrect.append(removed)
        state.shown.insert(removed.text)

        if state.cards.isEmpty {
            state.selectedIndex = nil
        } else if let selected = state.selectedIndex {
            if selected == index {
                state.selectedIndex = min(index, state.cards.count - 1)
            } else if selected > index {
                state.selectedIndex = selected - 1
            }
        }
    }

    /// Append suggestions at the end until the stack has `size` cards. Cards already visible
    /// keep their place. Not an Undo step of its own.
    public mutating func fill(with suggestions: [Suggestion]) {
        for suggestion in suggestions {
            guard state.cards.count < Self.size else { break }
            if state.cards.contains(where: { $0.text == suggestion.text }) { continue }
            state.cards.append(suggestion)
            state.shown.insert(suggestion.text)
        }
        if state.selectedIndex == nil && !state.cards.isEmpty {
            state.selectedIndex = 0
        }
    }

    public mutating func select(_ index: Int) {
        guard state.cards.indices.contains(index), state.selectedIndex != index else { return }
        history.append(state)
        state.selectedIndex = index
    }

    /// Revert the last change. Returns false when there is nothing to undo.
    @discardableResult
    public mutating func undo() -> Bool {
        guard let previous = history.popLast() else { return false }
        state = previous
        return true
    }

    private static func unique(_ suggestions: [Suggestion]) -> [Suggestion] {
        var seen = Set<String>()
        var result: [Suggestion] = []
        for suggestion in suggestions where !seen.contains(suggestion.text) {
            seen.insert(suggestion.text)
            result.append(suggestion)
        }
        return result
    }
}
