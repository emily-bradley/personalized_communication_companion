import SwiftUI
import XCTest
import SelvoCore
@testable import Selvo

/// Renders every screen in Nightlight and Daylight at the default and accessibility XL text
/// sizes, and writes PNGs to $SCREENSHOT_DIR (CI uploads them as the `screenshots` artifact).
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
    func snapshot<V: View>(_ name: String, @ViewBuilder _ view: @escaping () -> V) throws {
        for themeID in ThemeID.allCases {
            for (sizeName, size) in Self.sizes {
                let theme = Theme(themeID)
                let content = view()
                    .padding(.top, 48)
                    .padding(.bottom, 16)
                    .frame(width: 390, height: 844)
                    .background(theme.colors.surface)
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

    func testRoot() throws {
        try snapshot("00-root") { RootView() }
    }

    func testComponentGallery() throws {
        try snapshot("01-components") { ComponentGallery() }
    }
}
