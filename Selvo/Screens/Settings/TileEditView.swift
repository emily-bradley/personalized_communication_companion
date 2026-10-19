import SwiftUI
import SelvoCore

/// Tile editing for supporters, opened from Settings. Every tile in a category in position
/// order: rename it, hide it or show it again, or add a new one in the first free slot.
/// Hidden tiles keep their slot, so nothing on the grid moves. Changes save straight away.
struct TileEditView: View {
    @Environment(AppModel.self) private var model
    @Environment(\.theme) private var theme
    @Environment(\.dynamicTypeSize) private var typeSize
    let category: TileCategory

    @State private var renamingID: UUID?
    @State private var draftLabel = ""
    @FocusState private var isRenameFocused: Bool
    @State private var isAdding = false
    @State private var newName = ""
    @State private var newSymbol = TileEditView.symbols[0].name

    struct SymbolChoice: Hashable {
        let name: String
        let label: String
    }

    /// The pictures a new tile can start with. A photo can be added later on the grid.
    static let symbols: [SymbolChoice] = [
        SymbolChoice(name: "star", label: "Star"),
        SymbolChoice(name: "heart", label: "Heart"),
        SymbolChoice(name: "house", label: "House"),
        SymbolChoice(name: "cup.and.saucer", label: "Cup"),
        SymbolChoice(name: "fork.knife", label: "Food"),
        SymbolChoice(name: "car", label: "Car"),
        SymbolChoice(name: "tree", label: "Tree"),
        SymbolChoice(name: "person", label: "Person"),
        SymbolChoice(name: "music.note", label: "Music"),
        SymbolChoice(name: "sportscourt", label: "Sports"),
        SymbolChoice(name: "bed.double", label: "Bed"),
        SymbolChoice(name: "cart", label: "Shopping"),
    ]

    private let columns = [
        GridItem(.flexible(), spacing: Spacing.space2),
        GridItem(.flexible(), spacing: Spacing.space2),
        GridItem(.flexible(), spacing: Spacing.space2),
    ]

    var body: some View {
        let tiles = model.profile?.tiles(in: category) ?? []

        Screen {
            TopBar(title: "Edit \(category.title)") {
                BackButton(action: goBack)
            } trailing: {
                EmptyView()
            }

            // The 8pt inset leaves room for the selection ring on the picture choices.
            ScrollsWhenNeeded(inset: Spacing.space2) {
                VStack(alignment: .leading, spacing: Spacing.space3) {
                    Text("Hidden tiles keep their place, so nothing else moves.")
                        .textStyle(TypeScale.caption)
                        .foregroundStyle(theme.colors.inkMuted)
                        .fixedSize(horizontal: false, vertical: true)

                    ForEach(tiles) { tile in
                        if renamingID == tile.id {
                            renameRow(tile)
                        } else {
                            tileRow(tile)
                        }
                    }

                    if isAdding {
                        addForm
                    } else {
                        SetupAddRow(title: "Add a tile") {
                            isAdding = true
                        }
                    }
                }
                .padding(.vertical, Spacing.space1)
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .onDisappear {
            if renamingID != nil { finishRenaming() }
        }
    }

    // MARK: Rows

    private func tileRow(_ tile: TileItem) -> some View {
        // At accessibility sizes the toggle moves under the name so both stay readable.
        let layout = typeSize.isAccessibilitySize
            ? AnyLayout(VStackLayout(alignment: .leading, spacing: Spacing.space2))
            : AnyLayout(HStackLayout(spacing: Spacing.space3))

        return layout {
            Button {
                startRenaming(tile)
            } label: {
                HStack(spacing: Spacing.space3) {
                    thumbnail(tile)
                        .opacity(tile.isHidden ? 0.5 : 1)
                    VStack(alignment: .leading, spacing: 0) {
                        Text(tile.label)
                            .textStyle(TypeScale.label)
                            .foregroundStyle(tile.isHidden ? theme.colors.inkMuted : theme.colors.ink)
                            .multilineTextAlignment(.leading)
                            .fixedSize(horizontal: false, vertical: true)
                        if tile.isHidden {
                            Text("Hidden")
                                .textStyle(TypeScale.caption)
                                .foregroundStyle(theme.colors.inkMuted)
                        }
                    }
                    Spacer(minLength: 0)
                }
                .frame(minHeight: Spacing.touchMin)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel(tile.isHidden ? "\(tile.label), hidden" : tile.label)
            .accessibilityHint("Renames this tile")

            hideToggle(tile)
        }
        .modifier(EditRowCard())
    }

    private func renameRow(_ tile: TileItem) -> some View {
        HStack(spacing: Spacing.space3) {
            thumbnail(tile)
            TextField("", text: $draftLabel, prompt: Text("Name").foregroundColor(theme.colors.inkMuted))
                .textStyle(TypeScale.label)
                .foregroundStyle(theme.colors.ink)
                .submitLabel(.done)
                .onSubmit(finishRenaming)
                .focused($isRenameFocused)
                .frame(minHeight: Spacing.touchMin)
                .accessibilityLabel("Tile name")
                .onAppear { isRenameFocused = true }
            QuietButton(title: "Done", action: finishRenaming)
        }
        .modifier(EditRowCard())
    }

    /// "Hide" or "Show on grid": a 44pt outlined pill with an eye symbol.
    private func hideToggle(_ tile: TileItem) -> some View {
        let title = tile.isHidden ? "Show on grid" : "Hide"
        let symbol = tile.isHidden ? "eye" : "eye.slash"
        let id = tile.id
        let hide = !tile.isHidden
        return Button {
            model.update { profile in
                profile.setHidden(hide, tileID: id)
            }
        } label: {
            HStack(spacing: 6) {
                Image(systemName: symbol)
                    .imageScale(.medium)
                    .accessibilityHidden(true)
                Text(title)
                    .textStyle(TypeScale.label)
                    .lineLimit(1)
                    .fixedSize()
            }
            .padding(.horizontal, Spacing.space3)
            .frame(minHeight: ComponentMetrics.quietButtonHeight)
        }
        .buttonStyle(QuietButtonStyle(theme: theme))
        .accessibilityLabel(tile.isHidden ? "Show \(tile.label) on grid" : "Hide \(tile.label)")
    }

    /// The tile's photo or symbol on a 48pt round well, like the setup lists.
    @ViewBuilder private func thumbnail(_ tile: TileItem) -> some View {
        switch model.artwork(for: tile) {
        case .symbol(let name):
            Image(systemName: name)
                .font(.system(size: 22, weight: .regular))
                .foregroundStyle(theme.colors.teal)
                .frame(width: SetupMetrics.wellSide, height: SetupMetrics.wellSide)
                .background(Circle().fill(theme.colors.well(for: tile.tint)))
                .accessibilityHidden(true)
        case .image(let image):
            image
                .resizable()
                .scaledToFill()
                .frame(width: SetupMetrics.wellSide, height: SetupMetrics.wellSide)
                .clipShape(Circle())
                .accessibilityHidden(true)
        }
    }

    // MARK: Adding

    private var addForm: some View {
        VStack(alignment: .leading, spacing: Spacing.space3) {
            SetupSectionLabel(title: "New tile")
            SetupNameField(text: $newName, submit: addTile)
            SetupSectionLabel(title: "Picture")
            LazyVGrid(columns: columns, spacing: Spacing.space2) {
                ForEach(Self.symbols, id: \.self) { choice in
                    symbolButton(choice)
                }
            }
            .padding(.bottom, Spacing.space1)
            PrimaryButton(title: "Add", isEnabled: !isNewNameEmpty, action: addTile)
            QuietButton(title: "Cancel", fillsWidth: true, height: ComponentMetrics.largeQuietButtonHeight) {
                isAdding = false
                newName = ""
            }
        }
        .padding(Spacing.space3)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(RoundedRectangle(cornerRadius: Radius.md).fill(theme.colors.surfaceRaised))
        .overlay(RoundedRectangle(cornerRadius: Radius.md).strokeBorder(theme.colors.hairline, lineWidth: 1))
    }

    private func symbolButton(_ choice: SymbolChoice) -> some View {
        let isSelected = newSymbol == choice.name
        return Button {
            newSymbol = choice.name
        } label: {
            Image(systemName: choice.name)
                .font(.system(size: 26, weight: .regular))
                .foregroundStyle(theme.colors.teal)
                .frame(maxWidth: .infinity, minHeight: SetupMetrics.inputHeight)
                .background(
                    RoundedRectangle(cornerRadius: Radius.md)
                        .fill(isSelected ? theme.colors.surfaceBrandTint : theme.colors.surfaceSunken)
                )
                .focusRing(isSelected, cornerRadius: Radius.md)
                .contentShape(RoundedRectangle(cornerRadius: Radius.md))
        }
        .buttonStyle(.plain)
        .accessibilityLabel(choice.label)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    private var isNewNameEmpty: Bool {
        newName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private func addTile() {
        guard !isNewNameEmpty else { return }
        let name = newName
        let symbol = newSymbol
        let category = category
        model.update { profile in
            _ = profile.addTile(label: name, symbol: symbol, category: category)
        }
        newName = ""
        newSymbol = Self.symbols[0].name
        isAdding = false
    }

    // MARK: Renaming

    private func startRenaming(_ tile: TileItem) {
        if renamingID != nil { finishRenaming() }
        draftLabel = tile.label
        renamingID = tile.id
    }

    private func finishRenaming() {
        if let id = renamingID {
            let label = draftLabel
            model.update { profile in
                profile.renameTile(id, to: label)
            }
        }
        renamingID = nil
        isRenameFocused = false
    }

    private func goBack() {
        if !model.path.isEmpty {
            model.path.removeLast()
        }
    }
}

/// A list row card like the setup lists: raised surface, radius 16, hairline edge.
private struct EditRowCard: ViewModifier {
    @Environment(\.theme) private var theme

    func body(content: Content) -> some View {
        content
            .padding(.vertical, Spacing.space2)
            .padding(.horizontal, Spacing.space3)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(RoundedRectangle(cornerRadius: Radius.md).fill(theme.colors.surfaceRaised))
            .overlay(RoundedRectangle(cornerRadius: Radius.md).strokeBorder(theme.colors.hairline, lineWidth: 1))
    }
}
