import SwiftUI

/// Line drawings from the artboards where the SF Symbol differs in shape. Each is drawn in a
/// 24 unit box, like the artboard SVGs, and stroked by `Tile`.
private func unitPoint(_ rect: CGRect) -> (Double, Double) -> CGPoint {
    let unit = rect.width / 24
    return { x, y in CGPoint(x: rect.minX + x * unit, y: rect.minY + y * unit) }
}

/// The Places pin: a teardrop with a small circle inside.
struct PinGlyphShape: Shape {
    func path(in rect: CGRect) -> Path {
        let point = unitPoint(rect)
        let unit = rect.width / 24
        var path = Path()
        path.move(to: point(12, 21))
        path.addCurve(to: point(6, 10), control1: point(12, 21), control2: point(6, 15.5))
        path.addArc(center: point(12, 10), radius: 6 * unit,
                    startAngle: .degrees(180), endAngle: .degrees(360), clockwise: false)
        path.addCurve(to: point(12, 21), control1: point(18, 15.5), control2: point(12, 21))
        path.closeSubpath()
        path.addEllipse(in: CGRect(origin: point(9.8, 7.8), size: CGSize(width: 4.4 * unit, height: 4.4 * unit)))
        return path
    }
}

/// The Photos picture: a rounded frame, a sun and one hill line.
struct PhotoGlyphShape: Shape {
    func path(in rect: CGRect) -> Path {
        let point = unitPoint(rect)
        let unit = rect.width / 24
        var path = Path()
        path.addRoundedRect(
            in: CGRect(origin: point(3, 5), size: CGSize(width: 18 * unit, height: 14 * unit)),
            cornerSize: CGSize(width: 3 * unit, height: 3 * unit)
        )
        path.addEllipse(in: CGRect(origin: point(7, 8), size: CGSize(width: 4 * unit, height: 4 * unit)))
        path.move(to: point(21, 16))
        path.addLine(to: point(16, 11))
        path.addLine(to: point(8, 19))
        return path
    }
}
