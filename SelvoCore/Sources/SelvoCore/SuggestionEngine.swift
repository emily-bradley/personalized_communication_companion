import Foundation

/// Suggestions plus whether the saved phrases had to step in, so the UI can say so in a caption.
public struct SuggestionResult: Equatable, Sendable {
    public var suggestions: [Suggestion]
    public var usedFallback: Bool

    public init(suggestions: [Suggestion], usedFallback: Bool) {
        self.suggestions = suggestions
        self.usedFallback = usedFallback
    }
}

/// Asks the primary provider (for example an on-device model) and falls back to saved phrases
/// when there is no primary, when it is too slow, or when it returns too few suggestions.
public final class SuggestionEngine: Sendable {
    public let primary: (any SuggestionProvider)?
    public let fallback: SavedPhraseProvider
    /// Seconds to wait for the primary before using saved phrases.
    public let timeout: TimeInterval

    public init(
        primary: (any SuggestionProvider)? = nil,
        fallback: SavedPhraseProvider = SavedPhraseProvider(),
        timeout: TimeInterval = 1.5
    ) {
        self.primary = primary
        self.fallback = fallback
        self.timeout = timeout
    }

    /// The first stack of three for a new context.
    public func firstStack(for context: SuggestionContext) async -> SuggestionResult {
        await next(for: context, count: SuggestionStack.size, excluding: [])
    }

    /// Up to `count` suggestions not in `excluding`. Use for Another (3) and after Incorrect (1).
    public func next(for context: SuggestionContext, count: Int, excluding: Set<String>) async -> SuggestionResult {
        guard count > 0 else { return SuggestionResult(suggestions: [], usedFallback: false) }

        var chosen: [Suggestion] = []
        if let primary = primary,
           let fromPrimary = await Self.ask(primary, context: context, count: count, excluding: excluding, timeout: timeout) {
            var seen = excluding
            for suggestion in fromPrimary where !seen.contains(suggestion.text) {
                seen.insert(suggestion.text)
                chosen.append(suggestion)
                if chosen.count == count { break }
            }
            if chosen.count == count {
                return SuggestionResult(suggestions: chosen, usedFallback: false)
            }
        }

        let skip = excluding.union(chosen.map { $0.text })
        let extra = await fallback.suggestions(for: context, count: count - chosen.count, excluding: skip)
        return SuggestionResult(suggestions: chosen + extra, usedFallback: true)
    }

    /// Races the provider against a timer. Returns nil when the timer wins. The losing task is
    /// cancelled; a provider should stop work when its task is cancelled.
    private static func ask(
        _ provider: any SuggestionProvider,
        context: SuggestionContext,
        count: Int,
        excluding: Set<String>,
        timeout: TimeInterval
    ) async -> [Suggestion]? {
        let nanoseconds = UInt64(max(0, timeout) * 1_000_000_000)
        return await withTaskGroup(of: Optional<[Suggestion]>.self, returning: Optional<[Suggestion]>.self) { group in
            group.addTask {
                await provider.suggestions(for: context, count: count, excluding: excluding)
            }
            group.addTask {
                try? await Task.sleep(nanoseconds: nanoseconds)
                return nil
            }
            var first: [Suggestion]? = nil
            if let result = await group.next() {
                first = result
            }
            group.cancelAll()
            return first
        }
    }
}
