import Foundation

/// Saves and loads the profile as a JSON file. Nothing leaves the phone.
public struct ProfileStore: Sendable {
    public let fileURL: URL

    public init(fileURL: URL) {
        self.fileURL = fileURL
    }

    /// Application Support/Selvo/profile.json
    public static func standard() -> ProfileStore {
        let base = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        return ProfileStore(fileURL: base.appendingPathComponent("Selvo/profile.json"))
    }

    /// Folder for personal tile photos, next to the profile.
    public var photosDirectory: URL {
        fileURL.deletingLastPathComponent().appendingPathComponent("Photos", isDirectory: true)
    }

    /// The saved profile, or nil when none has been saved yet.
    public func load() throws -> Profile? {
        guard FileManager.default.fileExists(atPath: fileURL.path) else { return nil }
        let data = try Data(contentsOf: fileURL)
        return try JSONDecoder().decode(Profile.self, from: data)
    }

    /// Loads the saved profile. A file that cannot be read is moved aside, not lost,
    /// so the next save never writes over it. Returns nil in that case.
    public func loadKeepingUnreadable() -> Profile? {
        do {
            return try load()
        } catch {
            try? FileManager.default.moveItem(at: fileURL, to: unreadableURL)
            return nil
        }
    }

    /// Where an unreadable profile is kept: profile-unreadable-<time>.json beside it.
    var unreadableURL: URL {
        let stamp = Int(Date().timeIntervalSince1970)
        return fileURL.deletingLastPathComponent()
            .appendingPathComponent("profile-unreadable-\(stamp).json")
    }

    public func save(_ profile: Profile) throws {
        try FileManager.default.createDirectory(at: fileURL.deletingLastPathComponent(), withIntermediateDirectories: true)
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        try encoder.encode(profile).write(to: fileURL, options: .atomic)
    }

    /// Saves photo data under a new file name and returns the name to store on a tile.
    public func savePhoto(_ data: Data, fileExtension: String = "jpg") throws -> String {
        try FileManager.default.createDirectory(at: photosDirectory, withIntermediateDirectories: true)
        let name = UUID().uuidString + "." + fileExtension
        try data.write(to: photosDirectory.appendingPathComponent(name), options: .atomic)
        return name
    }

    public func photoURL(named name: String) -> URL {
        photosDirectory.appendingPathComponent(name)
    }

    public func delete() throws {
        if FileManager.default.fileExists(atPath: fileURL.path) {
            try FileManager.default.removeItem(at: fileURL)
        }
    }
}
