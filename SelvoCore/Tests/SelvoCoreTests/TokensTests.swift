import Foundation
import XCTest
@testable import SelvoCore

final class TokensTests: XCTestCase {
    /// docs/design/system/tokens.json, found relative to this file.
    private func loadTokens() throws -> [String: Any] {
        let repoRoot = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent() // SelvoCoreTests
            .deletingLastPathComponent() // Tests
            .deletingLastPathComponent() // SelvoCore
            .deletingLastPathComponent() // repo root
        let url = repoRoot.appendingPathComponent("docs/design/system/tokens.json")
        let data = try Data(contentsOf: url)
        return try XCTUnwrap(JSONSerialization.jsonObject(with: data) as? [String: Any])
    }

    private func hex(_ string: String) -> RGBA {
        RGBA(hex: UInt32(string.dropFirst(), radix: 16)!)
    }

    func testEveryColorTokenMatchesTokensJSON() throws {
        let json = try loadTokens()
        let color = try XCTUnwrap(json["color"] as? [String: Any])
        let tokens = try XCTUnwrap(color["tokens"] as? [[String: Any]])
        var byName: [String: Any] = [:]
        for token in tokens { byName[token["name"] as! String] = token["value"] }

        func resolve(_ value: Any?, theme: String) -> String {
            if let s = value as? String {
                if s.hasPrefix("{") { return resolve(byName[String(s.dropFirst().dropLast())], theme: theme) }
                return s
            }
            return (value as! [String: String])[theme]!
        }

        XCTAssertEqual(Set(Palette.tokenNames), Set(byName.keys))
        for name in byName.keys {
            XCTAssertEqual(Palette.night.color(named: name), hex(resolve(byName[name], theme: "night")), "night \(name)")
            XCTAssertEqual(Palette.day.color(named: name), hex(resolve(byName[name], theme: "day")), "day \(name)")
        }
    }

    func testTypeScaleMatchesTokensJSON() throws {
        let json = try loadTokens()
        let type = try XCTUnwrap(json["type"] as? [String: Any])
        let groups = try XCTUnwrap(type["groups"] as? [[String: Any]])
        let styles = groups.flatMap { $0["styles"] as! [[String: Any]] }
        XCTAssertEqual(styles.count, TypeScale.all.count)
        for style in styles {
            let name = style["name"] as! String
            let generated = try XCTUnwrap(TypeScale.all.first { $0.name == name }, name)
            XCTAssertEqual(generated.size, Double((style["fontSize"] as! String).replacingOccurrences(of: "px", with: "")))
            XCTAssertEqual(generated.lineHeight, Double((style["lineHeight"] as! String).replacingOccurrences(of: "px", with: "")))
            XCTAssertEqual(generated.weight, style["fontWeight"] as? Int)
        }
    }

    func testNothingShipsBelowFourteenPoints() {
        for style in TypeScale.all + [TypeScale.primaryAction] {
            XCTAssertGreaterThanOrEqual(style.size, 14, style.name)
        }
    }

    func testSemiboldIsTheHeaviestWeight() {
        for style in TypeScale.all + [TypeScale.primaryAction] {
            XCTAssertTrue(style.weight == 400 || style.weight == 600, style.name)
        }
    }

    func testSpacingAndRadiusValues() {
        XCTAssertEqual(Spacing.space4, 16)
        XCTAssertEqual(Spacing.space12, 48)
        XCTAssertEqual(Spacing.touchMin, 44)
        XCTAssertEqual(Spacing.touchTile, 96)
        XCTAssertEqual(Spacing.touchPrimary, 64)
        XCTAssertEqual(Radius.md, 16)
        XCTAssertEqual(Radius.lg, 24)
        XCTAssertEqual(Radius.pill, 999)
    }

    func testTextPairsMeetAAInBothThemes() {
        for theme in ThemeID.allCases {
            let p = theme.palette
            XCTAssertGreaterThanOrEqual(p.ink.contrast(with: p.surface), 7, "\(theme) ink on surface")
            XCTAssertGreaterThanOrEqual(p.ink.contrast(with: p.surfaceRaised), 7, "\(theme) ink on raised")
            XCTAssertGreaterThanOrEqual(p.ink.contrast(with: p.surfaceBrandTint), 7, "\(theme) ink on tint")
            XCTAssertGreaterThanOrEqual(p.inkMuted.contrast(with: p.surface), 4.5, "\(theme) muted on surface")
            XCTAssertGreaterThanOrEqual(p.inkMuted.contrast(with: p.surfaceSunken), 4.5, "\(theme) muted on sunken")
            XCTAssertGreaterThanOrEqual(p.teal.contrast(with: p.surface), 4.5, "\(theme) teal on surface")
            XCTAssertGreaterThanOrEqual(p.onPrimary.contrast(with: p.primary), 4.5, "\(theme) on-primary on primary")
            XCTAssertGreaterThanOrEqual(p.onPrimary.contrast(with: p.danger), 4.5, "\(theme) on-primary on danger")
            XCTAssertGreaterThanOrEqual(p.danger.contrast(with: p.surface), 4.5, "\(theme) danger on surface")
            XCTAssertGreaterThanOrEqual(p.borderStrong.contrast(with: p.surface), 3, "\(theme) control edge")
        }
    }

    func testThemeNames() {
        XCTAssertEqual(ThemeID.night.displayName, "Nightlight")
        XCTAssertEqual(ThemeID.day.displayName, "Daylight")
    }
}

final class ComponentMetricsTests: XCTestCase {
    func testEveryTappableElementMeetsTheTouchFloor() {
        for (name, height) in ComponentMetrics.allTappableHeights {
            XCTAssertGreaterThanOrEqual(height, Spacing.touchMin, name)
        }
    }

    func testSpeakIsSixtyFourPointsAndTilesNinetySix() {
        XCTAssertEqual(ComponentMetrics.primaryButtonHeight, 64)
        XCTAssertEqual(ComponentMetrics.tileMinSide, 96)
    }

    func testClearSitsFarFromSpeak() {
        XCTAssertGreaterThanOrEqual(ComponentMetrics.clearToSpeakMinDistance, 48)
    }

    func testReadingFontNames() {
        XCTAssertEqual(ReadingFont.lexend.postScriptName(semibold: false), "Lexend-Regular")
        XCTAssertEqual(ReadingFont.lexend.postScriptName(semibold: true), "Lexend-SemiBold")
        XCTAssertEqual(ReadingFont.atkinson.postScriptName(semibold: false), "AtkinsonHyperlegible-Regular")
    }
}
