import Foundation

/// The seeded profile for the demo: Lucas, with SF Symbols on tinted tiles. No photos of people.
public enum DemoProfile {
    public static var lucas: Profile {
        Profile(
            name: "Lucas",
            theme: .night,
            textSize: .standard,
            speechRate: 0.5,
            readingFont: .lexend,
            styles: [.plain, .witty, .short],
            helpTitle: "I need help.",
            helpPhrase: "Please call my sister Emily. Her number is on the back of this phone.",
            tiles: photos + places + people + phrases,
            hasCompletedSetup: true
        )
    }

    private static func make(_ category: TileCategory, _ items: [(String, String, TileTint, String?)]) -> [TileItem] {
        items.enumerated().map { index, item in
            TileItem(category: category, label: item.0, symbol: item.1, tint: item.2, note: item.3, position: index)
        }
    }

    static let photos = make(.photos, [
        ("Coffee", "cup.and.saucer", .brand, nil),
        ("Dinner", "fork.knife", .sunken, nil),
        ("Home", "house", .indigo, nil),
        ("Car", "car", .sunken, nil),
        ("Mom", "person.2", .brand, nil),
        ("Game", "sportscourt", .indigo, nil),
        ("Bed", "bed.double", .sunken, nil),
        ("Rosie", "pawprint", .brand, nil),
        ("Park", "tree", .indigo, nil),
        ("Music", "music.note", .sunken, nil),
        ("Movie", "film", .brand, nil),
        ("Beach", "beach.umbrella", .indigo, nil),
    ])

    static let places = make(.places, [
        ("Home", "house", .indigo, nil),
        ("Coffee shop", "cup.and.saucer", .brand, nil),
        ("Park", "tree", .sunken, nil),
        ("Store", "cart", .indigo, nil),
        ("Gym", "dumbbell", .sunken, nil),
        ("Restaurant", "fork.knife", .brand, nil),
        ("Work", "briefcase", .sunken, nil),
        ("Stadium", "sportscourt", .indigo, nil),
        ("Doctor", "cross.case", .sunken, nil),
    ])

    static let people = make(.people, [
        ("Mom", "person.2", .brand, "Every day"),
        ("Emily", "person.2", .indigo, "Sister"),
        ("Blake", "person.2", .sunken, "Brother-in-law"),
        ("Dad", "person.2", .indigo, nil),
        ("Rosie", "pawprint", .brand, "Dog"),
        ("Sam", "person.2", .sunken, "Friend"),
    ])

    static let phrases = make(.phrases, [
        ("Yes", "hand.thumbsup", .brand, nil),
        ("No", "hand.thumbsdown", .sunken, nil),
        ("Thank you", "heart", .indigo, nil),
        ("Wait", "hand.raised", .sunken, nil),
        ("Not that", "xmark", .sunken, nil),
        ("Again", "arrow.clockwise", .indigo, nil),
        ("Later", "clock", .sunken, nil),
        ("Funny", "face.smiling", .brand, nil),
        ("I don't know", "questionmark", .sunken, nil),
    ])
}
