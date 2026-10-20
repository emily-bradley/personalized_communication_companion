import Foundation

/// The four tile destinations on Home. Listen is the fifth destination and has no tiles.
public enum TileCategory: String, Codable, CaseIterable, Sendable {
    case photos
    case places
    case people
    case phrases

    public var title: String {
        switch self {
        case .photos: return "Photos"
        case .places: return "Places"
        case .people: return "People"
        case .phrases: return "Phrases"
        }
    }

    /// SF Symbol for the destination tile on Home.
    public var symbol: String {
        switch self {
        case .photos: return "photo"
        case .places: return "mappin.and.ellipse"
        case .people: return "person.2"
        case .phrases: return "text.bubble"
        }
    }
}

/// Which theme surface a symbol tile's well uses. Mapped to theme colors in the app.
public enum TileTint: String, Codable, CaseIterable, Sendable {
    case sunken
    case brand
    case indigo
}

public enum SuggestionStyle: String, Codable, CaseIterable, Sendable {
    case plain
    case witty
    case short
}

/// Three text sizes the supporter or the person can choose. Maps to Dynamic Type in the app.
public enum TextSize: String, Codable, CaseIterable, Sendable {
    case standard
    case large
    case larger
}

/// One communication tile. `position` is a fixed slot: tiles never reflow when others are
/// hidden or added.
public struct TileItem: Codable, Identifiable, Equatable, Sendable {
    public var id: UUID
    public var category: TileCategory
    public var label: String
    /// SF Symbol shown when there is no personal photo.
    public var symbol: String
    public var tint: TileTint
    /// File name of a personal photo in the profile's photo folder.
    public var photoFileName: String?
    /// A short note, such as "Every day" or "Sister" for people.
    public var note: String?
    public var position: Int
    public var isHidden: Bool

    public init(
        id: UUID = UUID(),
        category: TileCategory,
        label: String,
        symbol: String,
        tint: TileTint = .sunken,
        photoFileName: String? = nil,
        note: String? = nil,
        position: Int,
        isHidden: Bool = false
    ) {
        self.id = id
        self.category = category
        self.label = label
        self.symbol = symbol
        self.tint = tint
        self.photoFileName = photoFileName
        self.note = note
        self.position = position
        self.isHidden = isHidden
    }
}

/// Everything Selvo knows about one person. Stored as JSON on the phone only.
public struct Profile: Codable, Equatable, Sendable {
    public var name: String
    public var theme: ThemeID
    /// The theme chosen at setup. Settings names it; changing the theme later leaves it alone.
    /// Nil for profiles saved before it was recorded.
    public var setupTheme: ThemeID?
    public var textSize: TextSize
    /// 0 is slowest, 1 is fastest. The app maps this to the speech synthesizer's range.
    public var speechRate: Double
    public var voiceIdentifier: String?
    public var readingFont: ReadingFont
    public var styles: [SuggestionStyle]
    /// Large heading on the attention screen, for example "I need help."
    public var helpTitle: String
    /// The sentence under it, for example who to call.
    public var helpPhrase: String
    public var tiles: [TileItem]
    public var hasCompletedSetup: Bool

    public init(
        name: String,
        theme: ThemeID = .night,
        setupTheme: ThemeID? = nil,
        textSize: TextSize = .standard,
        speechRate: Double = 0.5,
        voiceIdentifier: String? = nil,
        readingFont: ReadingFont = .lexend,
        styles: [SuggestionStyle] = SuggestionStyle.allCases,
        helpTitle: String = "I need help.",
        helpPhrase: String = "",
        tiles: [TileItem] = [],
        hasCompletedSetup: Bool = false
    ) {
        self.name = name
        self.theme = theme
        self.setupTheme = setupTheme ?? theme
        self.textSize = textSize
        self.speechRate = speechRate
        self.voiceIdentifier = voiceIdentifier
        self.readingFont = readingFont
        self.styles = styles
        self.helpTitle = helpTitle
        self.helpPhrase = helpPhrase
        self.tiles = tiles
        self.hasCompletedSetup = hasCompletedSetup
    }

    public func tiles(in category: TileCategory) -> [TileItem] {
        tiles.filter { $0.category == category }.sorted { $0.position < $1.position }
    }
}

/// "Good evening, Lucas. Where would you like to start?"
public enum Greeting {
    public static func text(name: String, hour: Int) -> String {
        let part: String
        switch hour {
        case 5..<12: part = "Good morning"
        case 12..<17: part = "Good afternoon"
        default: part = "Good evening"
        }
        return "\(part), \(name). Where would you like to start?"
    }
}
