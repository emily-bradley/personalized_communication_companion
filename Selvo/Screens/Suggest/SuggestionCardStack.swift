import SwiftUI
import SelvoCore

/// The three suggestion cards, top aligned in the space between the strip and Another.
///
/// SuggestionCard never truncates its text, so at the largest text sizes three cards can be
/// taller than the space left. Instead of scrolling or clipping, this picks the largest version
/// that fits: the chosen text size, then capped sizes, then without the captions.
struct SuggestionCardStack: View {
    let cards: [Suggestion]
    let selectedIndex: Int?
    let personName: String
    let onSelect: (Int) -> Void

    var body: some View {
        ViewThatFits(in: .vertical) {
            list(showsCaptions: true)
            list(showsCaptions: true)
                .dynamicTypeSize(...DynamicTypeSize.xxLarge)
            list(showsCaptions: false)
                .dynamicTypeSize(...DynamicTypeSize.xxLarge)
            list(showsCaptions: false)
                .dynamicTypeSize(...DynamicTypeSize.large)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }

    private func list(showsCaptions: Bool) -> some View {
        VStack(spacing: Spacing.space3) {
            ForEach(Array(cards.enumerated()), id: \.element.id) { index, suggestion in
                SuggestionCard(
                    text: suggestion.text,
                    caption: showsCaptions ? suggestion.caption(personName: personName) : nil,
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
