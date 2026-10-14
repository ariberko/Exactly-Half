import SwiftUI

/// What a part does: "solid" has weight, "deco" is only paint, "hole" cuts a see-through hole.
enum PartRole { case solid, deco, hole }

enum PartShape {
    case ellipse(cx: Double, cy: Double, rx: Double, ry: Double, turn: Double)
    case rect(cx: Double, cy: Double, w: Double, h: Double, corner: Double, turn: Double)
    case poly([CGPoint])
    case capsule(x1: Double, y1: Double, x2: Double, y2: Double, r: Double)
}

/// One piece of an object. Objects live in a box from -1 to 1 (x right, y down).
/// Later parts cover earlier ones, both on screen and on the scale.
struct Part {
    let shape: PartShape
    let weight: Double
    let color: Color
    let role: PartRole

    static func ellipse(_ cx: Double, _ cy: Double, _ rx: Double, _ ry: Double, turn: Double = 0,
                        weight: Double = 0, color: UInt32, role: PartRole = .solid) -> Part {
        Part(shape: .ellipse(cx: cx, cy: cy, rx: rx, ry: ry, turn: turn), weight: weight, color: Color(hex: color), role: role)
    }

    static func rect(_ cx: Double, _ cy: Double, _ w: Double, _ h: Double, corner: Double = 0, turn: Double = 0,
                     weight: Double = 0, color: UInt32, role: PartRole = .solid) -> Part {
        Part(shape: .rect(cx: cx, cy: cy, w: w, h: h, corner: corner, turn: turn), weight: weight, color: Color(hex: color), role: role)
    }

    static func poly(_ points: [(Double, Double)], weight: Double = 0, color: UInt32, role: PartRole = .solid) -> Part {
        Part(shape: .poly(points.map { CGPoint(x: $0.0, y: $0.1) }), weight: weight, color: Color(hex: color), role: role)
    }

    static func capsule(_ x1: Double, _ y1: Double, _ x2: Double, _ y2: Double, _ r: Double,
                        weight: Double = 0, color: UInt32, role: PartRole = .solid) -> Part {
        Part(shape: .capsule(x1: x1, y1: y1, x2: x2, y2: y2, r: r), weight: weight, color: Color(hex: color), role: role)
    }

    /// The outline in object units.
    var path: Path {
        switch shape {
        case let .ellipse(cx, cy, rx, ry, turn):
            return Path(ellipseIn: CGRect(x: -rx, y: -ry, width: rx * 2, height: ry * 2))
                .applying(Self.place(cx, cy, turn))
        case let .rect(cx, cy, w, h, corner, turn):
            let box = CGRect(x: -w / 2, y: -h / 2, width: w, height: h)
            let shape = corner > 0 ? Path(roundedRect: box, cornerRadius: corner) : Path(box)
            return shape.applying(Self.place(cx, cy, turn))
        case let .poly(points):
            var path = Path()
            path.addLines(points)
            path.closeSubpath()
            return path
        case let .capsule(x1, y1, x2, y2, r):
            let length = hypot(x2 - x1, y2 - y1)
            let box = CGRect(x: -length / 2 - r, y: -r, width: length + r * 2, height: r * 2)
            let turn = atan2(y2 - y1, x2 - x1) * 180 / .pi
            return Path(roundedRect: box, cornerRadius: r).applying(Self.place((x1 + x2) / 2, (y1 + y2) / 2, turn))
        }
    }

    /// Is this point (in object units) inside the part? Same math as scripts/levels.py.
    func contains(_ x: Double, _ y: Double) -> Bool {
        switch shape {
        case let .ellipse(cx, cy, rx, ry, turn):
            let (lx, ly) = Self.unturn(x - cx, y - cy, turn)
            return (lx / rx) * (lx / rx) + (ly / ry) * (ly / ry) <= 1
        case let .rect(cx, cy, w, h, corner, turn):
            var (lx, ly) = Self.unturn(x - cx, y - cy, turn)
            lx = abs(lx)
            ly = abs(ly)
            let hw = w / 2, hh = h / 2
            if lx > hw || ly > hh { return false }
            let r = min(corner, hw, hh)
            let qx = lx - (hw - r), qy = ly - (hh - r)
            return !(qx > 0 && qy > 0 && qx * qx + qy * qy > r * r)
        case let .poly(points):
            var inside = false
            var j = points.count - 1
            for i in points.indices {
                let a = points[i], b = points[j]
                if (a.y > y) != (b.y > y) && x < (b.x - a.x) * (y - a.y) / (b.y - a.y) + a.x {
                    inside.toggle()
                }
                j = i
            }
            return inside
        case let .capsule(x1, y1, x2, y2, r):
            let dx = x2 - x1, dy = y2 - y1
            let t = max(0, min(1, ((x - x1) * dx + (y - y1) * dy) / max(dx * dx + dy * dy, 1e-9)))
            let ex = x - x1 - t * dx, ey = y - y1 - t * dy
            return ex * ex + ey * ey <= r * r
        }
    }

    private static func place(_ x: Double, _ y: Double, _ turn: Double) -> CGAffineTransform {
        CGAffineTransform(rotationAngle: turn * .pi / 180).concatenating(CGAffineTransform(translationX: x, y: y))
    }

    private static func unturn(_ x: Double, _ y: Double, _ turn: Double) -> (Double, Double) {
        let a = -turn * .pi / 180
        return (x * cos(a) - y * sin(a), x * sin(a) + y * cos(a))
    }
}

/// How an object is painted.
enum Look: Equatable {
    case full
    /// One flat color: you see the shape but not which parts are heavy.
    case silhouette
}

/// Something to cut in half. It is a class so its weighing grid is worked out only once.
final class Thing {
    let name: String
    let parts: [Part]

    init(name: String, parts: [Part]) {
        self.name = name
        self.parts = parts
    }

    private lazy var paths: [Path] = parts.map(\.path)

    // MARK: - Weighing

    /// The object chopped into a fine grid of tiny weights.
    private struct Grains {
        var x: [Double] = []
        var y: [Double] = []
        var mass: [Double] = []
        var total: Double = 0
    }

    private static let grid = 150
    private static let span = 1.15

    private lazy var grains: Grains = {
        var grains = Grains()
        let weighed = parts.filter { $0.role != .deco }.reversed()
        let step = 2 * Self.span / Double(Self.grid)
        for row in 0..<Self.grid {
            let y = -Self.span + (Double(row) + 0.5) * step
            for column in 0..<Self.grid {
                let x = -Self.span + (Double(column) + 0.5) * step
                guard let part = weighed.first(where: { $0.contains(x, y) }), part.role == .solid, part.weight > 0 else {
                    continue
                }
                grains.x.append(x)
                grains.y.append(y)
                grains.mass.append(part.weight)
                grains.total += part.weight
            }
        }
        return grains
    }()

    /// Where each grain lands left-to-right when the object is turned.
    private func across(_ i: Int, cos c: Double, sin s: Double) -> Double {
        grains.x[i] * c - grains.y[i] * s
    }

    /// Share of the weight (0...1) that ends up left of the cut, when the object's
    /// middle is `offset` units right of the cut and it is turned `turn` degrees.
    func leftShare(offset: Double, turn: Double) -> Double {
        let a = turn * .pi / 180
        let c = cos(a), s = sin(a)
        var left = 0.0
        for i in grains.mass.indices where across(i, cos: c, sin: s) + offset < 0 {
            left += grains.mass[i]
        }
        return grains.total > 0 ? left / grains.total : 0.5
    }

    private var perfectCache: [String: Double] = [:]

    /// The offset that leaves exactly `share` of the weight left of the cut
    /// (0.5 is two equal halves).
    func perfectOffset(turn: Double, share: Double = 0.5) -> Double {
        let key = "\(turn)|\(share)"
        if let known = perfectCache[key] { return known }
        let offset = findPerfectOffset(turn: turn, share: share)
        if perfectCache.count > 64 { perfectCache.removeAll() }
        perfectCache[key] = offset
        return offset
    }

    private func findPerfectOffset(turn: Double, share: Double) -> Double {
        let a = turn * .pi / 180
        let c = cos(a), s = sin(a)
        let order = grains.mass.indices.map { (across($0, cos: c, sin: s), grains.mass[$0]) }.sorted { $0.0 < $1.0 }
        var run = 0.0
        for (x, mass) in order {
            run += mass
            if run >= grains.total * share { return -x }
        }
        return 0
    }

    /// How far the object reaches up, down, left and right (in units) when turned.
    func reach(turn: Double) -> (left: Double, right: Double, top: Double, bottom: Double) {
        let a = turn * .pi / 180
        let c = cos(a), s = sin(a)
        var box = (left: 0.0, right: 0.0, top: 0.0, bottom: 0.0)
        for i in grains.mass.indices {
            let x = grains.x[i] * c - grains.y[i] * s
            let y = grains.x[i] * s + grains.y[i] * c
            box.left = min(box.left, x)
            box.right = max(box.right, x)
            box.top = min(box.top, y)
            box.bottom = max(box.bottom, y)
        }
        return box
    }

    /// Works out the weighing grid now, so the first cut doesn't stutter.
    func prepare() {
        _ = grains.total
        _ = paths.count
    }

    // MARK: - Drawing

    /// Paints the object. `transform` maps object units to the canvas.
    func draw(in context: GraphicsContext, transform: CGAffineTransform, look: Look = .full, opacity: Double = 1) {
        context.drawLayer { layer in
            layer.opacity = opacity
            for (part, path) in zip(parts, paths) {
                let shape = path.applying(transform)
                switch part.role {
                case .hole:
                    layer.blendMode = .destinationOut
                    layer.fill(shape, with: .color(.black))
                    layer.blendMode = .normal
                case .deco:
                    if look == .full { layer.fill(shape, with: .color(part.color)) }
                case .solid:
                    layer.fill(shape, with: .color(look == .full ? part.color : Theme.silhouette))
                }
            }
        }
    }
}

extension Color {
    init(hex: UInt32) {
        self.init(red: Double((hex >> 16) & 0xFF) / 255,
                  green: Double((hex >> 8) & 0xFF) / 255,
                  blue: Double(hex & 0xFF) / 255)
    }
}
