import Foundation

/// What happens to the object after a few seconds on "Now You See It" levels.
enum Hide { case none, silhouette, vanish }

/// One level. The level list itself is made by scripts/levels.py (LevelData.swift).
struct Level: Identifiable {
    let number: Int
    let thing: Thing
    /// How close to 50% you must be, in percent.
    let tolerance: Double
    /// Starting turn in degrees.
    var turn: Double = 0
    /// It rocks back and forth this many degrees.
    var wobble: Double = 0
    /// It slides by itself this far (in object sizes) and can't be dragged.
    var move: Double = 0
    /// Seconds for one wobble or slide.
    var period: Double = 3
    var hide: Hide = .none
    let tip: String
    var isDaily = false

    var id: Int { number }
    var name: String { thing.name }
    var isFree: Bool { isDaily || number <= Level.freeCount }

    static let freeCount = 3
    static let hideAfter: TimeInterval = 3

    /// How the object sits `time` seconds after it showed up.
    func pose(at time: TimeInterval, dragged: CGPoint, swingStart: Double) -> (offset: CGPoint, turn: Double) {
        let wave = 2 * Double.pi * time / period
        let turnNow = turn + wobble * sin(wave * 0.83)
        guard move > 0 else { return (dragged, turnNow) }
        // Swings across the perfect spot, fastest right when it's there.
        let center = thing.perfectOffset(turn: turn)
        return (CGPoint(x: center + move * sin(wave + swingStart), y: 0), turnNow)
    }

    /// Stars for a cut that was `error` percent away from 50%.
    func stars(error: Double) -> Int {
        if error <= tolerance / 5 { return 3 }
        if error <= tolerance / 2 { return 2 }
        if error <= tolerance { return 1 }
        return 0
    }

    var modifiers: [String] {
        var list: [String] = []
        if wobble > 0 { list.append("Wobbly") }
        if move > 0 { list.append("Moving") }
        switch hide {
        case .none: break
        case .silhouette: list.append("Colors fade")
        case .vanish: list.append("Vanishes")
        }
        return list
    }

    static func find(_ n: Int) -> Level? {
        all.first { $0.number == n }
    }

    static func chapter(of number: Int) -> String {
        chapters.last { $0.first <= number }?.name ?? ""
    }
}

// MARK: - Daily Cut

extension Level {
    /// Today's mystery object. Everyone gets the same one on the same day.
    static func daily(for date: Date = Date()) -> Level {
        var rng = SeededRandom(seed: UInt64(DayKey.from(date)))
        let names = ["Moon Cheese", "Space Rock", "Mystery Jelly", "Alien Cookie", "Lava Blob",
                     "Wobble Pie", "Dino Egg", "Cloud Cake", "Fudge Rock", "Comet Candy"]
        let palettes: [(UInt32, UInt32)] = [(0xFFB74D, 0x8D4E1A), (0x81D4FA, 0x1565C0), (0xCE93D8, 0x6A1B9A),
                                            (0xA5D6A7, 0x2E7D32), (0xFFF176, 0xF57F17), (0xF48FB1, 0xAD1457)]
        let (light, heavy) = palettes[rng.next(palettes.count)]

        // A lumpy blob, stretched sideways.
        var points: [(Double, Double)] = []
        let corners = 16
        for i in 0..<corners {
            let angle = Double(i) / Double(corners) * 2 * .pi
            let radius = 0.62 + rng.unit() * 0.33
            points.append((cos(angle) * radius, sin(angle) * radius * 0.72))
        }
        var parts: [Part] = [.poly(points, weight: 1, color: light)]
        // One or two heavy lumps hidden inside.
        for _ in 0..<(1 + rng.next(2)) {
            let x = (rng.unit() - 0.5) * 0.9
            let y = (rng.unit() - 0.5) * 0.4
            let r = 0.12 + rng.unit() * 0.14
            parts.append(.ellipse(x, y, r, r * 0.9, weight: 3 + rng.unit() * 3, color: heavy))
        }
        // Sometimes a hole.
        if rng.next(2) == 0 {
            let r = 0.08 + rng.unit() * 0.1
            parts.append(.ellipse((rng.unit() - 0.5) * 0.8, (rng.unit() - 0.5) * 0.3, r, r, color: 0, role: .hole))
        }

        var level = Level(number: 0, thing: Thing(name: names[rng.next(names.count)], parts: parts),
                          tolerance: 2, turn: (rng.unit() - 0.5) * 40, tip: "A new mystery every day. The dark lumps are heavy!")
        level.isDaily = true
        switch rng.next(4) {
        case 0: level.wobble = 10 + rng.unit() * 10
        case 1:
            level.move = 0.6 + rng.unit() * 0.3
            level.period = 3
        case 2: level.hide = .silhouette
        default: break
        }
        return level
    }
}

/// Days as numbers like 20261014, in the phone's own time zone.
enum DayKey {
    static func from(_ date: Date) -> Int {
        let parts = Calendar.current.dateComponents([.year, .month, .day], from: date)
        return (parts.year ?? 0) * 10000 + (parts.month ?? 0) * 100 + (parts.day ?? 0)
    }

    static func yesterday(of date: Date) -> Int {
        from(Calendar.current.date(byAdding: .day, value: -1, to: date) ?? date)
    }
}

/// A tiny random number maker that always gives the same numbers for the same seed.
struct SeededRandom {
    private var state: UInt64

    init(seed: UInt64) { state = seed &* 0x9E37_79B9_7F4A_7C15 | 1 }

    mutating func nextRaw() -> UInt64 {
        state &+= 0x9E37_79B9_7F4A_7C15
        var z = state
        z = (z ^ (z >> 30)) &* 0xBF58_476D_1CE4_E5B9
        z = (z ^ (z >> 27)) &* 0x94D0_49BB_1331_11EB
        return z ^ (z >> 31)
    }

    /// 0 up to (but not including) `count`.
    mutating func next(_ count: Int) -> Int { Int(nextRaw() % UInt64(max(count, 1))) }

    /// 0 up to 1.
    mutating func unit() -> Double { Double(nextRaw() >> 11) / Double(1 << 53) }
}
