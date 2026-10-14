import SwiftUI

/// Looks for the cut line. Classic is free, the rest come with the Blade Pack.
struct Blade: Identifiable, Equatable {
    enum Style { case dashed, beam, zigzag }

    let id: String
    let name: String
    let tagline: String
    let color: Color
    let glow: Double
    let width: CGFloat
    let style: Style
    let productID: String?

    static let classic = Blade(id: "classic", name: "Classic", tagline: "A clean kitchen knife.",
                               color: .white, glow: 0.3, width: 2, style: .dashed, productID: nil)
    static let laser = Blade(id: "laser", name: "Laser", tagline: "Pew pew. Super precise.",
                             color: Color(red: 1, green: 0.15, blue: 0.2), glow: 1, width: 3, style: .beam, productID: StoreIDs.blades)
    static let katana = Blade(id: "katana", name: "Katana", tagline: "Silent and shiny.",
                              color: Color(red: 0.85, green: 0.92, blue: 1), glow: 0.7, width: 4, style: .beam, productID: StoreIDs.blades)
    static let chainsaw = Blade(id: "chainsaw", name: "Chainsaw", tagline: "Loud. Very loud.",
                                color: Color(red: 1, green: 0.6, blue: 0.1), glow: 0.6, width: 3, style: .zigzag, productID: StoreIDs.blades)
    static let plasma = Blade(id: "plasma", name: "Plasma", tagline: "Hot purple energy.",
                              color: Color(red: 0.7, green: 0.35, blue: 1), glow: 1, width: 6, style: .beam, productID: StoreIDs.blades)

    static let all = [classic, laser, katana, chainsaw, plasma]

    static func with(id: String) -> Blade {
        all.first { $0.id == id } ?? .classic
    }

    /// Draws the blade as a line from top to bottom at x.
    func draw(in context: GraphicsContext, x: CGFloat, height: CGFloat, opacity: Double = 1) {
        var line = Path()
        switch style {
        case .zigzag:
            var y: CGFloat = 0
            line.move(to: CGPoint(x: x, y: 0))
            while y < height {
                y += 10
                line.addLine(to: CGPoint(x: x + (Int(y / 10) % 2 == 0 ? -4 : 4), y: y))
            }
        default:
            line.move(to: CGPoint(x: x, y: 0))
            line.addLine(to: CGPoint(x: x, y: height))
        }
        let dash: [CGFloat] = style == .dashed ? [10, 8] : []
        context.drawLayer { layer in
            layer.opacity = opacity
            layer.addFilter(.shadow(color: color.opacity(glow), radius: 10))
            layer.stroke(line, with: .color(color), style: StrokeStyle(lineWidth: width, lineCap: .round, dash: dash))
            if style == .beam {
                layer.stroke(line, with: .color(.white.opacity(0.8)), lineWidth: max(1, width / 3))
            }
        }
    }
}
