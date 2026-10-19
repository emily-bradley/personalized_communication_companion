import SwiftUI
import SelvoCore

/// Placeholder until the tile grid is built (see PLAN.md).
struct TileGridView: View {
    @Environment(AppModel.self) private var model
    let category: TileCategory

    var body: some View {
        Screen {
            TopBar(title: category.title) {
                BackButton { model.path.removeLast() }
            } trailing: {
                EmptyView()
            }
            Spacer()
        }
        .toolbar(.hidden, for: .navigationBar)
    }
}
