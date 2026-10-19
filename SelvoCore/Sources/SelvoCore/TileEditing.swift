import Foundation

/// Supporter tile editing. Every change keeps tile positions fixed: hiding leaves the slot
/// empty, unhiding fills the same slot, and a new tile takes the first free slot.
extension Profile {
    /// Hides or shows the tile with this id. Its position never changes.
    public mutating func setHidden(_ hidden: Bool, tileID: UUID) {
        guard let index = tiles.firstIndex(where: { $0.id == tileID }) else { return }
        tiles[index].isHidden = hidden
    }

    /// Adds a tile in the first free slot of its category and returns it. Returns nil and
    /// changes nothing when the label is empty after trimming.
    @discardableResult
    public mutating func addTile(label: String, symbol: String, category: TileCategory) -> TileItem? {
        let trimmed = label.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }
        let position = TileLayout().nextFreePosition(in: tiles(in: category))
        let tile = TileItem(category: category, label: trimmed, symbol: symbol, position: position)
        tiles.append(tile)
        return tile
    }

    /// Renames the tile with this id. An empty label after trimming is ignored.
    public mutating func renameTile(_ id: UUID, to label: String) {
        let trimmed = label.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, let index = tiles.firstIndex(where: { $0.id == id }) else { return }
        tiles[index].label = trimmed
    }
}
