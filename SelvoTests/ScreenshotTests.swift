import SwiftUI
import XCTest
import SelvoCore
@testable import Selvo

/// Renders every screen in Nightlight and Daylight at the default and accessibility XL text
/// sizes, and writes PNGs to $SCREENSHOT_DIR (CI uploads them as the `screenshots` artifact).
/// File names: <name>-<night|day>-<default|axl>.png
@MainActor
final class ScreenshotTests: XCTestCase {
    static let sizes: [(name: String, size: DynamicTypeSize)] = [("default", .large), ("axl", .accessibility3)]

    private var outputDirectory: URL {
        let path = ProcessInfo.processInfo.environment["SCREENSHOT_DIR"]
            ?? (NSTemporaryDirectory() as NSString).appendingPathComponent("screenshots")
        let url = URL(fileURLWithPath: path)
        try? FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
        return url
    }

    /// Renders a 390x844 frame with the iPhone safe areas approximated as padding.
    /// `configure` can change the model (for example to set a message) before rendering.
    func snapshot<V: View>(
        _ name: String,
        profile: Profile? = DemoProfile.lucas,
        configure: (AppModel) -> Void = { _ in },
        @ViewBuilder _ view: @escaping () -> V
    ) throws {
        for themeID in ThemeID.allCases {
            for (sizeName, size) in Self.sizes {
                var themed = profile
                themed?.theme = themeID
                let model = AppModel.preview(profile: themed)
                configure(model)
                let theme = Theme(themeID)
                let content = view()
                    .padding(.top, 48)
                    .padding(.bottom, 16)
                    .frame(width: 390, height: 844)
                    .background(theme.colors.surface)
                    .environment(model)
                    .environment(\.theme, theme)
                    .environment(\.dynamicTypeSize, size)
                    .environment(\.colorScheme, theme.colorScheme)
                let renderer = ImageRenderer(content: content)
                renderer.scale = 2
                let image = try XCTUnwrap(renderer.uiImage, "\(name) did not render")
                let data = try XCTUnwrap(image.pngData())
                let file = outputDirectory.appendingPathComponent("\(name)-\(themeID.rawValue)-\(sizeName).png")
                try data.write(to: file)
                XCTAssertEqual(image.size.width, 390)
            }
        }
    }

    func testComponentGallery() throws {
        try snapshot("00-components") { ComponentGallery() }
    }

    func testWelcome() throws {
        try snapshot("01-welcome", profile: nil) { WelcomeView() }
    }

    func testSetup() throws {
        try snapshot("02-setup", profile: nil) { SetupView() }
    }

    func testHome() throws {
        try snapshot("03-home") { HomeView() }
    }

    func testPhotos() throws {
        try snapshot("04-photos", configure: { model in
            let coffee = model.profile!.tiles(in: .photos)[0]
            model.selectedTile = coffee
            model.message = coffee.label
        }) { TileGridView(category: .photos) }
    }

    func testSuggest() throws {
        try snapshot("05-suggest") { SuggestView() }
    }

    func testShow() throws {
        try snapshot("06-show", configure: { $0.message = "Can we get coffee before work?" }) { ShowView() }
    }

    func testListen() throws {
        try snapshot("07-listen") { ListenView() }
    }

    func testHelp() throws {
        try snapshot("08-help") { HelpView() }
    }

    func testSettings() throws {
        try snapshot("09-settings") { SettingsView() }
    }
}
