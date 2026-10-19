import Foundation

/// Fixed-slot paging for tile grids. A slot is `position`; page n holds slots
/// n*pageSize ..< (n+1)*pageSize. Hidden tiles leave their slot empty, so nothing moves.
public struct TileLayout: Equatable, Sendable {
    public static let defaultPageSize = 9
    public let pageSize: Int

    public init(pageSize: Int = TileLayout.defaultPageSize) {
        precondition(pageSize > 0)
        self.pageSize = pageSize
    }

    /// Number of pages needed to show every slot that has a tile, hidden or not. At least 1.
    public func pageCount(for tiles: [TileItem]) -> Int {
        guard let last = tiles.map(\.position).max() else { return 1 }
        return last / pageSize + 1
    }

    /// The slots on one page in order. A slot is nil when empty or when its tile is hidden.
    public func slots(page: Int, tiles: [TileItem]) -> [TileItem?] {
        let start = page * pageSize
        var result = [TileItem?](repeating: nil, count: pageSize)
        for tile in tiles where !tile.isHidden && tile.position >= start && tile.position < start + pageSize {
            result[tile.position - start] = tile
        }
        return result
    }

    /// The first slot no tile occupies (hidden tiles keep their slot).
    public func nextFreePosition(in tiles: [TileItem]) -> Int {
        let taken = Set(tiles.map(\.position))
        var p = 0
        while taken.contains(p) { p += 1 }
        return p
    }
}
