import Foundation

/// Where a suggestion came from.
public enum SuggestionSource: String, Codable, Sendable {
    case savedPhrase
    case model
}

/// One suggested sentence the person can choose, change, or mark Incorrect.
public struct Suggestion: Codable, Equatable, Identifiable, Sendable {
    public var id: UUID
    public var text: String
    public var style: SuggestionStyle
    public var source: SuggestionSource

    public init(id: UUID = UUID(), text: String, style: SuggestionStyle, source: SuggestionSource) {
        self.id = id
        self.text = text
        self.style = style
        self.source = source
    }

    /// The small line under a card, for example "Suggested for Lucas · witty".
    public func caption(personName: String) -> String {
        "Suggested for \(personName) \u{00B7} \(style.rawValue)"
    }
}

/// What the person is talking about right now: the tile they picked, or what they just heard.
public struct SuggestionContext: Equatable, Sendable {
    public var personName: String
    public var tileLabel: String?
    public var category: TileCategory?
    public var heardText: String?
    /// Style tags to offer, in order. Empty means all styles.
    public var styles: [SuggestionStyle]

    public init(
        personName: String,
        tileLabel: String? = nil,
        category: TileCategory? = nil,
        heardText: String? = nil,
        styles: [SuggestionStyle] = SuggestionStyle.allCases
    ) {
        self.personName = personName
        self.tileLabel = tileLabel
        self.category = category
        self.heardText = heardText
        self.styles = styles
    }

    public init(profile: Profile, tile: TileItem?, heardText: String? = nil) {
        self.init(
            personName: profile.name,
            tileLabel: tile?.label,
            category: tile?.category,
            heardText: heardText,
            styles: profile.styles
        )
    }
}

/// Anything that can offer suggestions: an on-device or remote model, or the saved phrases.
public protocol SuggestionProvider: Sendable {
    /// Returns up to `count` suggestions whose text is not in `excluding`.
    func suggestions(for context: SuggestionContext, count: Int, excluding: Set<String>) async -> [Suggestion]
}

public extension Array where Element == Suggestion {
    /// The same suggestions with those in `style` first, each group in its own order. After
    /// Incorrect, the new card keeps the style of the one it replaces when it can.
    func preferring(_ style: SuggestionStyle?) -> [Suggestion] {
        guard let style else { return self }
        return filter { $0.style == style } + filter { $0.style != style }
    }
}
