import Foundation

/// The three suggestion cards on the Suggest screen and the rules around them.
///
/// Another replaces the whole stack. Incorrect removes one card and logs it, leaving its slot
/// open; `fill(with:)` then puts the next suggestion in that same slot, so no other card moves.
/// Every change except `fill(with:)` can be undone; a fill completes the change before it, so
/// one Undo after Incorrect brings back the original three.
public struct SuggestionStack: Equatable, Sendable {
    public static let size = 3

    private struct State: Equatable, Sendable {
        /// Fixed card positions. `nil` is a slot opened by Incorrect and not filled yet.
        var slots: [Suggestion?] = []
        var selectedSlot: Int?
        var shown: Set<String> = []
        var incorrect: [Suggestion] = []
    }

    private var state = State()
    private var history: [State] = []

    public init() {}

    /// The visible cards, never more than `size`.
    public var cards: [Suggestion] { state.slots.compactMap { $0 } }

    /// Index into `cards` of the selected card. 0 whenever the stack has cards and nothing else
    /// was chosen. Nil while the selected card's slot waits to be filled.
    public var selectedIndex: Int? {
        guard let slot = state.selectedSlot, state.slots.indices.contains(slot),
              state.slots[slot] != nil else { return nil }
        return state.slots[..<slot].compactMap { $0 }.count
    }

    /// Every text that has been on screen in this stack.
    public var shown: Set<String> { state.shown }
    /// Cards marked Incorrect, oldest first. This is the feedback log for the model.
    public var incorrect: [Suggestion] { state.incorrect }

    public var selected: Suggestion? {
        guard let slot = state.selectedSlot, state.slots.indices.contains(slot) else { return nil }
        return state.slots[slot]
    }

    /// Texts a provider should not offer again.
    public var excluded: Set<String> {
        state.shown.union(state.incorrect.map { $0.text })
    }

    /// True when a card is missing, for example right after Incorrect.
    public var needsFill: Bool { cards.count < Self.size }

    public var canUndo: Bool { !history.isEmpty }

    /// Another, or the first stack: replace every card.
    public mutating func replaceAll(with suggestions: [Suggestion]) {
        history.append(state)
        state.slots = Array(Self.unique(suggestions).prefix(Self.size))
        for card in cards { state.shown.insert(card.text) }
        state.selectedSlot = state.slots.isEmpty ? nil : 0
    }

    /// Incorrect: remove one card and log it. Its slot stays open, and stays selected if it was,
    /// so the card from `fill(with:)` takes its place and its selection.
    public mutating func markIncorrect(at index: Int) {
        guard let slot = slot(forCard: index), let removed = state.slots[slot] else { return }
        history.append(state)
        state.slots[slot] = nil
        state.incorrect.append(removed)
        state.shown.insert(removed.text)
    }

    /// Fill open slots first, top to bottom, then add at the end until the stack has `size`
    /// cards. Cards already visible keep their place. Not an Undo step of its own.
    public mutating func fill(with suggestions: [Suggestion]) {
        var queue = suggestions.filter { suggestion in
            !cards.contains(where: { $0.text == suggestion.text })
        }
        queue = Self.unique(queue)
        for slot in state.slots.indices where state.slots[slot] == nil && !queue.isEmpty {
            state.slots[slot] = queue.removeFirst()
        }
        while cards.count < Self.size, !queue.isEmpty {
            state.slots.append(queue.removeFirst())
        }
        for card in cards { state.shown.insert(card.text) }

        // Close slots nothing could fill, so the remaining cards sit together.
        if state.slots.contains(where: { $0 == nil }) {
            let selectedCard = selected
            state.slots = cards
            state.selectedSlot = selectedCard.flatMap { card in cards.firstIndex(of: card) }
        }
        if selected == nil {
            state.selectedSlot = state.slots.isEmpty ? nil : 0
        }
    }

    public mutating func select(_ index: Int) {
        guard let slot = slot(forCard: index), state.selectedSlot != slot else { return }
        history.append(state)
        state.selectedSlot = slot
    }

    /// Revert the last change. Returns false when there is nothing to undo.
    @discardableResult
    public mutating func undo() -> Bool {
        guard let previous = history.popLast() else { return false }
        state = previous
        return true
    }

    /// The slot that holds `cards[index]`.
    private func slot(forCard index: Int) -> Int? {
        guard index >= 0 else { return nil }
        var seen = 0
        for (slot, card) in state.slots.enumerated() where card != nil {
            if seen == index { return slot }
            seen += 1
        }
        return nil
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
