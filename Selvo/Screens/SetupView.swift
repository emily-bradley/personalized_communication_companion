import SwiftUI
import SelvoCore

/// Placeholder until the Setup screen is built (see PLAN.md).
struct SetupView: View {
    @Environment(AppModel.self) private var model

    var body: some View {
        Screen {
            TopBar(title: "Setup") {
                BackButton { model.path.removeLast() }
            } trailing: {
                EmptyView()
            }
            Spacer()
        }
        .toolbar(.hidden, for: .navigationBar)
    }
}
