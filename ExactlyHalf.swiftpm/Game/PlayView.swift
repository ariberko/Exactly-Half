import SwiftUI

/// Sizes shared by the play screen and the scale.
enum Sizing {
    /// Points per object unit, so the object fits with room to slide.
    static func scale(for size: CGSize) -> CGFloat {
        min(size.width * 0.25, size.height * 0.4)
    }
}

/// The level itself: line the object up over the hinge, then fold to cut.
struct PlayView: View {
    @ObservedObject var game: Game
    let blade: Blade
    let openShop: () -> Void

    @State private var dragStart: CGPoint?

    var body: some View {
        GeometryReader { geo in
            let frame = FoldFrame(screen: geo.size, turned: game.turnFold)
            ZStack {
                switch game.phase {
                case .waitingToOpen:
                    openPrompt
                        .padding(.top, geo.safeAreaInsets.top)
                        .padding(.bottom, geo.safeAreaInsets.bottom)
                case .aiming:
                    aiming(frame: frame, insets: geo.safeAreaInsets)
                case .chopped:
                    ChopView(blade: blade, folded: game.isFolded, since: game.choppedAt)
                case .result:
                    if let cut = game.cut {
                        ResultView(game: game, cut: cut, blade: blade, openShop: openShop)
                            .padding(.top, max(geo.safeAreaInsets.top, 12))
                            .padding(.bottom, max(geo.safeAreaInsets.bottom, 12))
                            .padding(.leading, geo.safeAreaInsets.leading)
                            .padding(.trailing, geo.safeAreaInsets.trailing)
                    }
                }
            }
            .frame(width: geo.size.width, height: geo.size.height)
        }
        .ignoresSafeArea()
    }

    // MARK: - Aiming

    private func aiming(frame: FoldFrame, insets: EdgeInsets) -> some View {
        ZStack {
            TimelineView(.animation) { timeline in
                ZStack {
                    Canvas { context, _ in
                        drawBoard(context, frame: frame, date: timeline.date)
                    }
                    .ignoresSafeArea()
                    countdown(at: timeline.date)
                }
            }
            .contentShape(Rectangle())
            .gesture(drag(frame: frame))

            hud(insets: insets)
        }
    }

    private func drawBoard(_ context: GraphicsContext, frame: FoldFrame, date: Date) {
        var context = context
        context.concatenate(frame.toScreen)
        let size = frame.size
        let mid = size.width / 2
        context.fill(Path(CGRect(x: 0, y: 0, width: mid, height: size.height)),
                     with: .color(Theme.halves[0].opacity(0.05)))
        context.fill(Path(CGRect(x: mid, y: 0, width: mid, height: size.height)),
                     with: .color(Theme.halves[1].opacity(0.05)))

        let level = game.level
        let time = date.timeIntervalSince(game.shownAt)
        let pose = game.pose(at: date)
        let s = Sizing.scale(for: size)
        let center = CGPoint(x: mid + pose.offset.x * s, y: size.height / 2 + pose.offset.y * s)
        let transform = CGAffineTransform(scaleX: s, y: s)
            .concatenating(CGAffineTransform(rotationAngle: pose.turn * .pi / 180))
            .concatenating(CGAffineTransform(translationX: center.x, y: center.y))
        let hidden = time > Level.hideAfter

        switch level.hide {
        case .none:
            level.thing.draw(in: context, transform: transform)
        case .silhouette:
            level.thing.draw(in: context, transform: transform, look: hidden ? .silhouette : .full)
        case .vanish:
            let fade = max(0, min(1, (Level.hideAfter - time) / 0.5))
            if fade > 0 {
                level.thing.draw(in: context, transform: transform, opacity: fade)
            }
            if hidden {
                // Only a little target is left, so you know where the middle is.
                let ring = CGRect(x: center.x - 10, y: center.y - 10, width: 20, height: 20)
                context.stroke(Path(ellipseIn: ring), with: .color(.white.opacity(0.5)), lineWidth: 2)
                context.fill(Path(ellipseIn: ring.insetBy(dx: 7, dy: 7)), with: .color(.white.opacity(0.5)))
            }
        }

        blade.draw(in: context, x: mid, height: size.height)
    }

    @ViewBuilder
    private func countdown(at date: Date) -> some View {
        let level = game.level
        let left = Level.hideAfter - date.timeIntervalSince(game.shownAt)
        if level.hide != .none && left > 0 {
            VStack(spacing: 2) {
                Text(level.hide == .vanish ? "VANISHES IN" : "COLORS FADE IN")
                    .font(Theme.title(13))
                Text("\(Int(left.rounded(.up)))")
                    .font(Theme.title(44))
            }
            .foregroundStyle(Theme.gold)
            .shadow(color: .black, radius: 6)
            .allowsHitTesting(false)
            .frame(maxHeight: .infinity, alignment: .top)
            .padding(.top, 90)
        }
    }

    private func drag(frame: FoldFrame) -> some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged { value in
                guard game.level.move == 0 else { return }
                let start = dragStart ?? game.dragged
                if dragStart == nil { dragStart = start }
                let move = frame.fromScreen(value.translation)
                let s = Sizing.scale(for: frame.size)
                let limitX = frame.size.width / 2 / s
                let limitY = frame.size.height / 2 / s * 0.6
                game.dragged = CGPoint(x: max(-limitX, min(limitX, start.x + move.width / s)),
                                       y: max(-limitY, min(limitY, start.y + move.height / s)))
            }
            .onEnded { _ in dragStart = nil }
    }

    // MARK: - Words and buttons on top

    private func hud(insets: EdgeInsets) -> some View {
        let level = game.level
        return VStack(spacing: 10) {
            HStack(alignment: .top, spacing: 12) {
                backButton
                VStack(alignment: .leading, spacing: 2) {
                    Text(level.isDaily ? "DAILY CUT" : "LEVEL \(level.number)")
                        .font(Theme.title(13))
                        .foregroundStyle(.white.opacity(0.6))
                    Text(level.name)
                        .font(Theme.title(20))
                        .foregroundStyle(.white)
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 4) {
                    pill("±\(Self.percent(level.tolerance))", color: Theme.good)
                    ForEach(level.modifiers, id: \.self) { pill($0, color: Theme.gold) }
                }
            }
            Spacer()
            VStack(spacing: 10) {
                Text(level.tip)
                    .font(Theme.body(14))
                    .foregroundStyle(.white.opacity(0.75))
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: 360)
                HStack(spacing: 8) {
                    Image(systemName: level.move > 0 ? "timer" : "hand.draw")
                    Text(level.move > 0 ? "Fold your phone at the right moment" : "Drag it, then fold your phone to cut")
                }
                .font(Theme.body(14, weight: .bold))
                .foregroundStyle(.white)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(.black.opacity(0.4), in: Capsule())
                if game.cutButton {
                    NeonButton(title: "✂︎  CUT", color: blade.color == .white ? Theme.halves[1] : blade.color) {
                        game.chop(byFold: false)
                    }
                }
            }
            .allowsHitTesting(game.cutButton)
        }
        .padding(.horizontal, 16)
        .padding(.top, max(insets.top, 12))
        .padding(.bottom, max(insets.bottom, 16))
        .padding(.leading, insets.leading)
        .padding(.trailing, insets.trailing)
    }

    private var backButton: some View {
        Button {
            game.leave()
        } label: {
            Image(systemName: "chevron.left")
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(.white)
                .frame(width: 40, height: 40)
                .background(.white.opacity(0.12), in: Circle())
        }
        .buttonStyle(.plain)
    }

    private func pill(_ text: String, color: Color) -> some View {
        Text(text)
            .font(Theme.title(13))
            .foregroundStyle(color)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(color.opacity(0.15), in: Capsule())
    }

    static func percent(_ value: Double) -> String {
        value == value.rounded() ? "\(Int(value))%" : String(format: "%.1f%%", value)
    }

    // MARK: - Open your phone

    private var openPrompt: some View {
        VStack(spacing: 18) {
            HStack {
                backButton
                Spacer()
            }
            .padding(.horizontal, 16)
            Spacer()
            Image(systemName: "rectangle.split.2x1")
                .font(.system(size: 54, weight: .bold))
                .foregroundStyle(Theme.halves[0])
                .shadow(color: Theme.halves[0], radius: 12)
            Text("Open your iPhone Duo")
                .font(Theme.title(26))
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)
            Text("\(game.level.isDaily ? "Daily Cut" : "Level \(game.level.number)"): \(game.level.name)")
                .font(Theme.title(17))
                .foregroundStyle(Theme.halves[1])
            Text("The hinge is your knife. Line the object up on the open screen, then fold to cut it in half.")
                .font(Theme.body(14))
                .foregroundStyle(.white.opacity(0.6))
                .multilineTextAlignment(.center)
                .frame(maxWidth: 320)
            Spacer()
            Button("No fold? Use a CUT button") { game.useCutButton() }
                .font(Theme.body(14, weight: .semibold))
                .foregroundStyle(.white.opacity(0.7))
        }
        .padding(.vertical, 12)
    }
}

/// The moment of the cut. Folded, it asks you to open up and see the scale.
struct ChopView: View {
    let blade: Blade
    let folded: Bool
    let since: Date

    var body: some View {
        TimelineView(.animation) { timeline in
            let t = timeline.date.timeIntervalSince(since)
            ZStack {
                Canvas { context, size in
                    // The blade sweeps down, then the flash fades.
                    let sweep = min(1, t / 0.25)
                    let fade = max(0, 1 - max(0, t - 0.25) / 0.6)
                    blade.draw(in: context, x: size.width / 2, height: size.height * sweep, opacity: 0.4 + 0.6 * fade)
                    context.fill(Path(CGRect(origin: .zero, size: size)), with: .color(blade.color.opacity(0.25 * fade)))
                }
                .ignoresSafeArea()
                VStack(spacing: 12) {
                    Text("CHOP!")
                        .font(Theme.title(56))
                        .foregroundStyle(.white)
                        .shadow(color: blade.color, radius: 16)
                        .scaleEffect(1 + 0.3 * max(0, 1 - t / 0.3))
                    if folded {
                        Label("Open your phone to weigh the halves", systemImage: "scalemass")
                            .font(Theme.body(16, weight: .bold))
                            .foregroundStyle(.white.opacity(0.8))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 20)
                    }
                }
            }
        }
    }
}
