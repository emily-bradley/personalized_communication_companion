import SwiftUI
import PhotosUI
import SelvoCore

/// Tile grid (App-Photos), shared by Photos, Places, People and Phrases: three columns of fixed
/// slots in pages of nine. Empty slots keep their space so nothing ever reflows.
struct TileGridView: View {
    @Environment(AppModel.self) private var model
    let category: TileCategory

    @State private var page = 0
    /// The tile a photo is being chosen or removed for.
    @State private var photoTileID: UUID?
    @State private var showsPhotoPicker = false
    @State private var pickedPhoto: PhotosPickerItem?
    @State private var confirmsRemovePhoto = false
    /// Rows are 118pt at the default text size and grow with larger text when there is room.
    @ScaledMetric(relativeTo: .body) private var rowHeight: Double = 118

    private let layout = TileLayout()
    private let columns = 3

    var body: some View {
        let tiles = model.profile?.tiles(in: category) ?? []
        let pageCount = layout.pageCount(for: tiles)
        let current = min(page, pageCount - 1)
        let slots = layout.slots(page: current, tiles: tiles)

        Screen {
            TopBar(title: category.title) {
                BackButton { model.path.removeLast() }
            } trailing: {
                HelpButton { model.open(.help) }
            }

            MessageStrip(message: model.message, placeholder: "Tap a picture to start.")

            VStack(spacing: Spacing.space3) {
                ForEach(0..<(slots.count / columns), id: \.self) { row in
                    HStack(spacing: Spacing.space3) {
                        ForEach(0..<columns, id: \.self) { column in
                            slot(slots[row * columns + column])
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                        }
                    }
                    .frame(minHeight: ComponentMetrics.tileMinSide, maxHeight: rowHeight)
                }
            }
            .dynamicTypeSize(...DynamicTypeSize.accessibility1)
            .frame(maxHeight: .infinity, alignment: .top)
            .contentShape(Rectangle())
            .simultaneousGesture(
                DragGesture(minimumDistance: 30).onEnded { value in
                    let dx = value.translation.width
                    guard abs(dx) > abs(value.translation.height), abs(dx) > 50 else { return }
                    page = dx < 0 ? min(current + 1, pageCount - 1) : max(current - 1, 0)
                }
            )

            if pageCount > 1 {
                PageDots(count: pageCount, page: Binding(get: { current }, set: { page = $0 }))
            }

            PrimaryButton(title: "Speak", isEnabled: !model.message.isEmpty) {
                model.speak()
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .photosPicker(isPresented: $showsPhotoPicker, selection: $pickedPhoto, matching: .images)
        .onChange(of: pickedPhoto) { _, item in
            guard let item, let id = photoTileID else { return }
            Task {
                if let data = try? await item.loadTransferable(type: Data.self) {
                    model.setPhoto(data, forTile: id)
                }
                pickedPhoto = nil
                photoTileID = nil
            }
        }
        .confirmationDialog("Remove this photo from the tile?", isPresented: $confirmsRemovePhoto, titleVisibility: .visible) {
            Button("Remove photo", role: .destructive) {
                if let id = photoTileID { model.removePhoto(fromTile: id) }
                photoTileID = nil
            }
            Button("Cancel", role: .cancel) {
                photoTileID = nil
            }
        }
    }

    @ViewBuilder private func slot(_ tile: TileItem?) -> some View {
        if let tile {
            Tile(
                label: tile.label,
                artwork: model.artwork(for: tile),
                isSelected: model.selectedTile?.id == tile.id
            ) {
                model.selectedTile = tile
                model.message = tile.label
                model.open(.suggest)
            }
            .contextMenu {
                Button("Choose a photo", systemImage: "photo") { choosePhoto(for: tile) }
                if tile.photoFileName != nil {
                    Button("Remove photo", systemImage: "trash", role: .destructive) { askToRemovePhoto(for: tile) }
                }
            }
            // The same choices for VoiceOver, in the Actions rotor.
            .accessibilityActions {
                Button("Choose a photo") { choosePhoto(for: tile) }
                if tile.photoFileName != nil {
                    Button("Remove photo") { askToRemovePhoto(for: tile) }
                }
            }
        } else {
            Color.clear
                .accessibilityHidden(true)
        }
    }

    private func choosePhoto(for tile: TileItem) {
        photoTileID = tile.id
        showsPhotoPicker = true
    }

    private func askToRemovePhoto(for tile: TileItem) {
        photoTileID = tile.id
        confirmsRemovePhoto = true
    }
}
