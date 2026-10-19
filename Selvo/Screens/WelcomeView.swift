import SwiftUI
import SelvoCore

/// Placeholder until the Welcome screen is built (see PLAN.md).
struct WelcomeView: View {
    @Environment(AppModel.self) private var model

    var body: some View {
        Screen {
            TopBar(title: "Welcome") {
                BackButton { model.path.removeLast() }
            } trailing: {
                EmptyView()
            }
            Spacer()
        }
        .toolbar(.hidden, for: .navigationBar)
    }
}
