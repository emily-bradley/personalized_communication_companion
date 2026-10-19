import SwiftUI
import SelvoCore

/// Placeholder until the Settings screen is built (see PLAN.md).
struct SettingsView: View {
    @Environment(AppModel.self) private var model

    var body: some View {
        Screen {
            TopBar(title: "Settings") {
                BackButton { model.path.removeLast() }
            } trailing: {
                EmptyView()
            }
            Spacer()
        }
        .toolbar(.hidden, for: .navigationBar)
    }
}
