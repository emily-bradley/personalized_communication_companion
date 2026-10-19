import SwiftUI
import SelvoCore

/// The three suggestion cards, top aligned in the space between the strip and Another.
///
/// Cards always use the person's text size and keep their captions. When three cards are
/// taller than the space at the largest text sizes, they scroll between the Show and Undo row
/// and the pinned Another, Incorrect and Speak.
struct SuggestionCardStack: View {
    let cards: [Suggestion]
    let selectedIndex: Int?
    let personName: String
    let onSelect: (Int) -> Void

    var body: some View {
        // The 8pt inset leaves room for the selection ring, drawn 2pt outside a card.
        ScrollsWhenNeeded(inset: Spacing.space2) {
            list
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }

    private var list: some View {
        VStack(spacing: Spacing.space3) {
            ForEach(Array(cards.enumerated()), id: \.element.id) { index, suggestion in
                SuggestionCard(
                    text: suggestion.text,
                    caption: suggestion.caption(personName: personName),
                    isSelected: selectedIndex == index
                ) {
                    onSelect(index)
                }
                .accessibilityHint("Puts this in your message")
            }
        }
        .frame(maxWidth: .infinity, alignment: .top)
    }
}
