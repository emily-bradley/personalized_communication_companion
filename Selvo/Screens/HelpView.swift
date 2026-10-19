import SwiftUI
import SelvoCore

/// Placeholder until the Help screen is built (see PLAN.md).
struct HelpView: View {
    @Environment(AppModel.self) private var model

    var body: some View {
        Screen {
            TopBar(title: "Help") {
                BackButton { model.path.removeLast() }
            } trailing: {
                EmptyView()
            }
            Spacer()
        }
        .toolbar(.hidden, for: .navigationBar)
    }
}
