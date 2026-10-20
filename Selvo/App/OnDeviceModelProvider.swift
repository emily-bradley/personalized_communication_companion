import Foundation
import SelvoCore
#if canImport(FoundationModels)
import FoundationModels
#endif

/// Suggestions from Apple's on-device model when the phone supports it (iOS 26 with Apple
/// Intelligence). Nothing leaves the phone. Returns nil everywhere else, and the engine falls
/// back to saved phrases, so the screen never waits on it.
enum OnDeviceModelProvider {
    static func makeIfAvailable() -> (any SuggestionProvider)? {
        #if canImport(FoundationModels)
        if #available(iOS 26.0, *), case .available = SystemLanguageModel.default.availability {
            return FoundationModelsProvider()
        }
        #endif
        return nil
    }
}

#if canImport(FoundationModels)
@available(iOS 26.0, *)
struct FoundationModelsProvider: SuggestionProvider {
    func suggestions(for context: SuggestionContext, count: Int, excluding: Set<String>) async -> [Suggestion] {
        let topic = context.tileLabel ?? context.heardText ?? "the conversation"
        let styles = context.styles.isEmpty ? SuggestionStyle.allCases : context.styles
        let instructions = """
        You suggest short things an adult named \(context.personName) might say out loud. \
        Write in the first person, as \(context.personName). Warm, direct, adult. \
        Never childish, never clinical. One sentence each, under 12 words, no exclamation marks.
        """
        var results: [Suggestion] = []
        do {
            let session = LanguageModelSession(instructions: instructions)
            for index in 0..<count {
                let style = styles[index % styles.count]
                let avoid = (excluding.union(results.map(\.text))).joined(separator: " | ")
                let prompt = "Topic: \(topic). Style: \(style.rawValue). Do not repeat: \(avoid). Reply with the sentence only."
                let response = try await session.respond(to: prompt)
                let text = response.content.trimmingCharacters(in: .whitespacesAndNewlines.union(CharacterSet(charactersIn: "\"")))
                if !text.isEmpty, !excluding.contains(text), Self.fitsCopyRules(text) {
                    results.append(Suggestion(text: text, style: style, source: .model))
                }
            }
        } catch {
            return results
        }
        return results
    }

    /// One plain sentence: no exclamation marks, no long dashes, no line breaks. Anything else
    /// is dropped and saved phrases fill the slot.
    static func fitsCopyRules(_ text: String) -> Bool {
        !text.contains(where: { "!\u{2014}\u{2013}\n".contains($0) })
    }
}
#endif
