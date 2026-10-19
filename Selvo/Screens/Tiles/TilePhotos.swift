import SwiftUI
import UIKit
import SelvoCore

/// Personal photos on tiles: what a tile shows, and adding or removing its photo.
extension AppModel {
    /// The tile's personal photo when it has one that loads, otherwise its SF Symbol.
    func artwork(for tile: TileItem) -> TileArtwork {
        if let name = tile.photoFileName,
           let image = UIImage(contentsOfFile: store.photoURL(named: name).path) {
            return .image(Image(uiImage: image))
        }
        return .symbol(tile.symbol)
    }

    /// Downscales picked image data, saves it, and puts it on the tile with this id.
    func setPhoto(_ data: Data, forTile id: UUID) {
        guard let image = UIImage(data: data),
              let jpeg = TilePhotos.downscaled(image).jpegData(compressionQuality: 0.85),
              let name = try? store.savePhoto(jpeg) else { return }
        let old = profile?.tiles.first(where: { $0.id == id })?.photoFileName
        update { profile in
            if let index = profile.tiles.firstIndex(where: { $0.id == id }) {
                profile.tiles[index].photoFileName = name
            }
        }
        if let old { TilePhotos.deleteFile(named: old, in: store) }
    }

    /// Takes the photo off the tile with this id; the tile shows its symbol again.
    func removePhoto(fromTile id: UUID) {
        let old = profile?.tiles.first(where: { $0.id == id })?.photoFileName
        update { profile in
            if let index = profile.tiles.firstIndex(where: { $0.id == id }) {
                profile.tiles[index].photoFileName = nil
            }
        }
        if let old { TilePhotos.deleteFile(named: old, in: store) }
    }
}

enum TilePhotos {
    /// Longest side of a saved tile photo, in pixels. Enough for a tile at 3x.
    static let maxSide: CGFloat = 600

    static func downscaled(_ image: UIImage) -> UIImage {
        let longest = max(image.size.width, image.size.height)
        let factor = longest > maxSide ? maxSide / longest : 1
        let size = CGSize(width: (image.size.width * factor).rounded(), height: (image.size.height * factor).rounded())
        let format = UIGraphicsImageRendererFormat.default()
        format.scale = 1
        format.opaque = true
        return UIGraphicsImageRenderer(size: size, format: format).image { _ in
            image.draw(in: CGRect(origin: .zero, size: size))
        }
    }

    static func deleteFile(named name: String, in store: ProfileStore) {
        try? FileManager.default.removeItem(at: store.photoURL(named: name))
    }
}
