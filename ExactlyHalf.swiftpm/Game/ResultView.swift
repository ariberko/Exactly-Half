import SwiftUI

/// After the cut: the two halves slide apart onto a balance scale, the scale tips,
/// and you see how close to exactly half you got.
struct ResultView: View {
    @ObservedObject var game: Game
    let cut: Cut
    let blade: Blade
    let openShop: () -> Void

    @EnvironmentObject private var store: Store
    @State private var settled = false

    private static let slide = 0.6
    private static let weigh = 1.2
    private static var done: Double { slide + weigh + 0.1 }

    var body: some View {
        TimelineView(.animation(paused: settled)) { timeline in
            let t = settled ? 10 : timeline.date.timeIntervalSince(game.revealedAt)
            VStack(spacing: 10) {
                header(shown: t >= Self.done)
                percentages(t: t)
                Canvas { context, size in
                    drawScale(context, size: size, t: t)
                }
                .frame(minHeight: 140)
                if t >= Self.done {
                    footer
                        .transition(.opacity)
                }
            }
            .padding(.horizontal, 16)
            .animation(.easeOut(duration: 0.3), value: t >= Self.done)
        }
        .task {
            try? await Task.sleep(for: .seconds(Self.done))
            if cut.stars > 0 { Haptics.win() } else { Haptics.ouch() }
            try? await Task.sleep(for: .seconds(0.5))
            settled = true
        }
    }

    // MARK: - Words

    private var message: String {
        if cut.error < 0.05 { return "EXACTLY HALF!" }
        switch cut.stars {
        case 3: return "Razor sharp!"
        case 2: return "Nice cut!"
        case 1: return "Close enough!"
        default: return "Too uneven!"
        }
    }

    private func header(shown: Bool) -> some View {
        VStack(spacing: 6) {
            Text(message)
                .font(Theme.title(34))
                .foregroundStyle(cut.stars > 0 ? Theme.gold : .white)
                .shadow(color: cut.stars > 0 ? Theme.gold.opacity(0.7) : .clear, radius: 12)
                .minimumScaleFactor(0.5)
                .lineLimit(1)
            StarsView(count: cut.stars, size: 26)
            Text(cut.stars > 0
                 ? "Off by only \(Self.precise(cut.error))"
                 : "Off by \(Self.precise(cut.error)). Get within ±\(PlayView.percent(game.level.tolerance)) to pass.")
                .font(Theme.body(14, weight: .semibold))
                .foregroundStyle(.white.opacity(0.7))
                .multilineTextAlignment(.center)
        }
        .opacity(shown ? 1 : 0)
    }

    /// Two big numbers that count up while the scale tips.
    private func percentages(t: Double) -> some View {
        let count = Self.ease((t - Self.slide) / Self.weigh)
        let left = cut.leftShare * 100 * count
        let right = (1 - cut.leftShare) * 100 * count
        return HStack {
            Text(Self.precise(left)).foregroundStyle(Theme.halves[0])
            Spacer()
            Text("|").foregroundStyle(.white.opacity(0.3))
            Spacer()
            Text(Self.precise(right)).foregroundStyle(Theme.halves[1])
        }
        .font(Theme.title(36))
        .monospacedDigit()
        .frame(maxWidth: 420)
    }

    private var footer: some View {
        VStack(spacing: 12) {
            PerfectCutView(thing: game.level.thing, cut: cut, blade: blade)
                .frame(width: 200, height: 70)
            HStack(spacing: 12) {
                NeonButton(title: "RETRY", color: .white.opacity(0.85), small: true) { game.retry() }
                nextButton
            }
            Button(game.level.isDaily ? "Menu" : "All levels") { game.leave() }
                .font(Theme.body(15, weight: .semibold))
                .foregroundStyle(.white.opacity(0.7))
        }
    }

    @ViewBuilder
    private var nextButton: some View {
        if cut.stars > 0, let next = game.nextLevel {
            if next.isFree || store.owns(StoreIDs.fullGame) {
                NeonButton(title: "NEXT", small: true) { game.play(next) }
            } else {
                NeonButton(title: "UNLOCK 30 MORE", color: Theme.gold, small: true) { openShop() }
            }
        } else if cut.stars > 0 && !game.level.isDaily {
            NeonButton(title: "YOU WON!", color: Theme.gold, small: true) { game.leave() }
        }
    }

    // MARK: - The scale

    private func drawScale(_ context: GraphicsContext, size: CGSize, t: Double) {
        let reach = cut.reach
        let offset = Double(cut.offset.x)
        let leftWidth = CGFloat(max(0.3, -(reach.left + offset)))
        let rightWidth = CGFloat(max(0.3, reach.right + offset))
        let tall = CGFloat(max(0.5, reach.bottom - reach.top))
        let s: CGFloat = min(size.width * 0.36 / max(leftWidth, rightWidth), size.height * 0.55 / tall, 160)

        let mid = size.width / 2
        let beamY = size.height * 0.84
        let arm = size.width * 0.34

        // Tip toward the heavier side. Small misses still show a little tilt.
        let tilt = CGFloat(max(-0.3, min(0.3, (cut.leftShare - 0.5) * 4)) * Self.bounce((t - Self.slide) / Self.weigh))
        let leftEnd = CGPoint(x: mid - arm * cos(tilt), y: beamY + arm * sin(tilt))
        let rightEnd = CGPoint(x: mid + arm * cos(tilt), y: beamY - arm * sin(tilt))

        // Stand.
        var stand = Path()
        stand.move(to: CGPoint(x: mid, y: beamY))
        stand.addLine(to: CGPoint(x: mid - 22, y: size.height - 2))
        stand.addLine(to: CGPoint(x: mid + 22, y: size.height - 2))
        stand.closeSubpath()
        context.fill(stand, with: .color(.white.opacity(0.25)))

        // Beam and plates.
        var beam = Path()
        beam.move(to: leftEnd)
        beam.addLine(to: rightEnd)
        context.stroke(beam, with: .color(.white.opacity(0.8)), style: StrokeStyle(lineWidth: 5, lineCap: .round))
        context.fill(Path(ellipseIn: CGRect(x: mid - 6, y: beamY - 6, width: 12, height: 12)), with: .color(.white))
        let plateWidth = min(size.width * 0.26, s * 2.2)
        for (end, color) in [(leftEnd, Theme.halves[0]), (rightEnd, Theme.halves[1])] {
            let plate = CGRect(x: end.x - plateWidth / 2, y: end.y - 9, width: plateWidth, height: 7)
            context.fill(Path(roundedRect: plate, cornerRadius: 3.5), with: .color(color))
        }

        // The halves slide from the cut to their plates.
        let apart = CGFloat(Self.ease(t / Self.slide))
        let restY = beamY - 10 - CGFloat(reach.bottom) * s
        let leftEdge = mid + (leftEnd.x + leftWidth * s / 2 - mid) * apart
        let rightEdge = mid + (rightEnd.x - rightWidth * s / 2 - mid) * apart
        let leftY = restY + leftEnd.y - beamY
        let rightY = restY + rightEnd.y - beamY

        drawHalf(context, edge: leftEdge, y: leftY, scale: s, keepLeft: true, width: size.width)
        drawHalf(context, edge: rightEdge, y: rightY, scale: s, keepLeft: false, width: size.width)

        // A flash along the cut right at the start.
        if t < 0.35 {
            blade.draw(in: context, x: mid, height: size.height * 0.8, opacity: 1 - t / 0.35)
        }
    }

    /// Draws one half. `edge` is where its cut side sits.
    private func drawHalf(_ context: GraphicsContext, edge: CGFloat, y: CGFloat, scale s: CGFloat,
                          keepLeft: Bool, width: CGFloat) {
        let center = CGPoint(x: edge + cut.offset.x * s, y: y)
        let transform = CGAffineTransform(scaleX: s, y: s)
            .concatenating(CGAffineTransform(rotationAngle: cut.turn * .pi / 180))
            .concatenating(CGAffineTransform(translationX: center.x, y: center.y))
        var layer = context
        let keep = keepLeft
            ? CGRect(x: -10_000, y: -10_000, width: edge + 10_000, height: 20_000)
            : CGRect(x: edge, y: -10_000, width: 20_000, height: 20_000)
        layer.clip(to: Path(keep))
        game.level.thing.draw(in: layer, transform: transform)
    }

    // MARK: - Helpers

    static func precise(_ value: Double) -> String {
        String(format: "%.1f%%", value)
    }

    static func ease(_ x: Double) -> Double {
        let x = max(0, min(1, x))
        return 1 - pow(1 - x, 3)
    }

    /// Eases in with a little wobble at the end, like a real scale.
    static func bounce(_ x: Double) -> Double {
        let x = max(0, min(1, x))
        return 1 - cos(x * .pi * 2.5) * exp(-x * 4.5)
    }
}

/// A small picture: your cut line and the perfect one, so you learn for next time.
struct PerfectCutView: View {
    let thing: Thing
    let cut: Cut
    let blade: Blade

    var body: some View {
        HStack(spacing: 10) {
            Canvas { context, size in
                let reach = cut.reach
                let wide = CGFloat(max(0.1, reach.right - reach.left))
                let tall = CGFloat(max(0.1, reach.bottom - reach.top))
                let s = min(size.width / wide, size.height / tall) * 0.9
                let objectX = size.width / 2 - CGFloat(reach.left + reach.right) / 2 * s
                let objectY = size.height / 2 - CGFloat(reach.top + reach.bottom) / 2 * s
                let transform = CGAffineTransform(scaleX: s, y: s)
                    .concatenating(CGAffineTransform(rotationAngle: cut.turn * .pi / 180))
                    .concatenating(CGAffineTransform(translationX: objectX, y: objectY))
                thing.draw(in: context, transform: transform, opacity: 0.8)

                // Your cut was where the object's middle sat `offset` from the line.
                let yours = objectX - cut.offset.x * s
                let perfect = objectX - CGFloat(cut.perfectOffset) * s
                line(context, x: yours, height: size.height, color: blade.color == .white ? .white : blade.color, dashed: false)
                line(context, x: perfect, height: size.height, color: Theme.good, dashed: true)
            }
            .frame(width: 110)
            VStack(alignment: .leading, spacing: 4) {
                Label("Your cut", systemImage: "line.diagonal")
                    .foregroundStyle(blade.color == .white ? .white : blade.color)
                Label("Perfect", systemImage: "line.diagonal")
                    .foregroundStyle(Theme.good)
            }
            .font(Theme.body(12, weight: .bold))
        }
    }

    private func line(_ context: GraphicsContext, x: CGFloat, height: CGFloat, color: Color, dashed: Bool) {
        var path = Path()
        path.move(to: CGPoint(x: x, y: 0))
        path.addLine(to: CGPoint(x: x, y: height))
        context.stroke(path, with: .color(color), style: StrokeStyle(lineWidth: 2, dash: dashed ? [4, 3] : []))
    }
}
