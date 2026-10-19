import SwiftUI
import SelvoCore

/// Placeholder until the Suggest screen is built (see PLAN.md).
struct SuggestView: View {
    @Environment(AppModel.self) private var model

    var body: some View {
        Screen {
            TopBar(title: "Suggest") {
                BackButton { model.path.removeLast() }
            } trailing: {
                EmptyView()
            }
            Spacer()
        }
        .toolbar(.hidden, for: .navigationBar)
    }
}
