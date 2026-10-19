import SwiftUI
import SelvoCore

/// Choose your words (App-Suggest): the message strip, Show and Undo, a stack of exactly three
/// suggestions, Another and Incorrect, and Speak.
///
/// Saved phrases fill the stack at once so the screen is never blank. When an on-device model
/// is available its first stack replaces them, but only if the person has not touched anything
/// yet; after that, model suggestions are fetched ahead of time and used by Another and
/// Incorrect when ready. Cards never change on their own once the person has started.
struct SuggestView: View {
    @Environment(AppModel.self) private var model
    @Environment(\.theme) private var theme

    @State private var stack = SuggestionStack()
    /// True once `stack` holds the first cards and the strip has been set from them.
    @State private var started = false
    /// True after any tap on this screen; the model's first stack is then ignored.
    @State private var touched = false
    @State private var askedEngine = false
    /// Model suggestions fetched ahead of time for the next Another or Incorrect.
    @State private var prefetched: [Suggestion] = []
    @State private var showsSpoken = false

    private let saved = SavedPhraseProvider()

    var body: some View {
        // Before onAppear runs (and in snapshots, which never run it) show the first saved
        // phrases so the layout is the same from the first frame.
        let visible = started ? stack : firstSavedStack
        let stripText = started ? model.message : (visible.selected?.text ?? model.message)

        Screen {
            TopBar(title: model.selectedTile?.label ?? "Your words") {
                BackButton { goBack() }
            } trailing: {
                QuietButton(title: "Clear") {
                    model.clearMessage()
                    model.goHome()
                }
                .accessibilityHint("Clears the message and goes back to Home")
            }

            VStack(spacing: Spacing.space2) {
                MessageStrip(message: stripText, placeholder: "Choose a suggestion below.")
                HStack {
                    LinkButton(title: "Show", systemImage: "text.alignleft") {
                        startIfNeeded()
                        model.open(.show)
                    }
                    .accessibilityHint("Shows your message large, turned toward the listener")
                    Spacer(minLength: Spacing.space4)
                    UndoButton(isEnabled: started && stack.canUndo) { undo() }
                }
                .dynamicTypeSize(...DynamicTypeSize.accessibility1)
            }

            SuggestionCardStack(
                cards: visible.cards,
                selectedIndex: visible.selectedIndex,
                personName: context.personName
            ) { index in
                select(index)
            }

            ZStack {
                if showsSpoken {
                    spokenRow.transition(.opacity)
                } else {
                    actionRow.transition(.opacity)
                }
            }
            .frame(minHeight: Spacing.touchMin)
            .animation(.easeInOut(duration: 0.2), value: showsSpoken)
            .dynamicTypeSize(...DynamicTypeSize.xxxLarge)

            PrimaryButton(title: "Speak", isEnabled: !stripText.isEmpty) {
                touched = true
                startIfNeeded()
                model.speak()
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .onAppear { startIfNeeded() }
        .task { await useModelFirstStack() }
        .task(id: stack.cards.map { $0.text }) { await prefetch() }
        .task(id: model.lastSpokenAt) { await showSpokenBriefly() }
    }

    // MARK: Rows

    private var actionRow: some View {
        HStack(spacing: Spacing.space3) {
            QuietButton(title: "Another", fillsWidth: true) { another() }
                .accessibilityHint("Shows three different suggestions")
            QuietButton(title: "Incorrect", fillsWidth: true) { incorrect() }
                .accessibilityHint("Removes the selected suggestion and adds a new one")
        }
    }

    private var spokenRow: some View {
        HStack(spacing: Spacing.space2) {
            Image(systemName: "checkmark")
                .font(.system(size: 20, weight: .semibold))
                .accessibilityHidden(true)
            Text("Spoken").textStyle(TypeScale.label)
        }
        .foregroundStyle(theme.colors.teal)
        .frame(maxWidth: .infinity, minHeight: Spacing.touchMin)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Spoken")
    }

    // MARK: Suggestions

    private var context: SuggestionContext {
        if let profile = model.profile {
            return SuggestionContext(profile: profile, tile: model.selectedTile)
        }
        return SuggestionContext(
            personName: "you",
            tileLabel: model.selectedTile?.label,
            category: model.selectedTile?.category
        )
    }

    private var firstSavedStack: SuggestionStack {
        var first = SuggestionStack()
        first.fill(with: saved.phrases(for: context, count: SuggestionStack.size, excluding: []))
        return first
    }

    /// Fills the stack with saved phrases the first time. `fill` is not an Undo step, so Undo
    /// can never empty the screen.
    private func startIfNeeded() {
        guard !started else { return }
        stack = firstSavedStack
        started = true
        syncMessage()
    }

    private func useModelFirstStack() async {
        guard !askedEngine else { return }
        askedEngine = true
        let result = await model.suggestions.firstStack(for: context)
        guard !result.usedFallback, !touched, !result.suggestions.isEmpty else { return }
        var fresh = SuggestionStack()
        fresh.fill(with: result.suggestions)
        stack = fresh
        started = true
        syncMessage()
    }

    private func prefetch() async {
        guard started, model.suggestions.primary != nil else { return }
        let result = await model.suggestions.next(
            for: context,
            count: SuggestionStack.size,
            excluding: stack.excluded
        )
        if !result.usedFallback && !Task.isCancelled {
            prefetched = result.suggestions
        }
    }

    /// The next `count` suggestions: prefetched model ones when there are enough, otherwise
    /// saved phrases. When every saved phrase has been shown, they start over, skipping only
    /// the cards on screen and those marked Incorrect.
    private func nextSuggestions(count: Int) -> [Suggestion] {
        let skip = stack.excluded
        let fromModel = prefetched.filter { !skip.contains($0.text) }
        if fromModel.count >= count {
            return Array(fromModel.prefix(count))
        }
        let next = saved.phrases(for: context, count: count, excluding: skip)
        if next.count >= count { return next }
        var keep = Set(stack.cards.map { $0.text })
        keep.formUnion(stack.incorrect.map { $0.text })
        keep.formUnion(next.map { $0.text })
        return next + saved.phrases(for: context, count: count - next.count, excluding: keep)
    }

    private func syncMessage() {
        if let text = stack.selected?.text {
            model.message = text
        }
    }

    // MARK: Actions

    private func select(_ index: Int) {
        touched = true
        startIfNeeded()
        stack.select(index)
        syncMessage()
    }

    private func another() {
        touched = true
        startIfNeeded()
        let next = nextSuggestions(count: SuggestionStack.size)
        guard !next.isEmpty else { return }
        stack.replaceAll(with: next)
        syncMessage()
    }

    private func incorrect() {
        touched = true
        startIfNeeded()
        guard let index = stack.selectedIndex else { return }
        stack.markIncorrect(at: index)
        if stack.needsFill {
            stack.fill(with: nextSuggestions(count: SuggestionStack.size - stack.cards.count))
        }
        syncMessage()
    }

    private func undo() {
        touched = true
        guard stack.undo() else { return }
        syncMessage()
    }

    private func goBack() {
        if !model.path.isEmpty {
            model.path.removeLast()
        }
    }

    /// After Speak, Another and Incorrect make way for "Spoken" for about a second. This is the
    /// only thing on the screen that goes away by itself.
    private func showSpokenBriefly() async {
        guard model.isShowingSpoken() else {
            showsSpoken = false
            return
        }
        showsSpoken = true
        try? await Task.sleep(nanoseconds: 1_200_000_000)
        guard !Task.isCancelled else { return }
        showsSpoken = false
    }
}
