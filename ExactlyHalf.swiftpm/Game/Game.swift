import SwiftUI
import UIKit

enum Screen { case menu, levels, play }

/// One go at a level:
/// waitingToOpen -> aiming -> (fold) chopped -> (open) result.
enum Phase { case waitingToOpen, aiming, chopped, result }

/// What happened when the blade came down.
struct Cut {
    let offset: CGPoint
    let turn: Double
    /// Share of the weight left of the cut (0...1).
    let leftShare: Double
    /// Where the object should have been for a perfect cut.
    let perfectOffset: Double
    let reach: (left: Double, right: Double, top: Double, bottom: Double)
    let stars: Int

    /// How far from 50/50, in percent.
    var error: Double { abs(leftShare - 0.5) * 100 }
}

/// Runs the game: which screen is up, where the object is, and the cut.
@MainActor
final class Game: ObservableObject {
    @Published var screen: Screen = .menu
    @Published private(set) var phase: Phase = .waitingToOpen
    @Published private(set) var level: Level = Level.all[0]
    @Published private(set) var cut: Cut?
    /// Where you dragged the object, in object sizes from the hinge.
    @Published var dragged = CGPoint.zero

    /// Show a CUT button, for phones and iPads that can't fold.
    @Published var cutButton: Bool {
        didSet { UserDefaults.standard.set(cutButton, forKey: "cutButton") }
    }
    /// The hinge runs the other way on this phone.
    @Published var turnFold: Bool {
        didSet { UserDefaults.standard.set(turnFold, forKey: "turnFold") }
    }

    private(set) var shownAt = Date()
    private(set) var choppedAt = Date()
    private(set) var revealedAt = Date()
    private(set) var swingStart = 0.0
    private var posture: Posture = .closed
    private let scorebook: Scorebook

    init(scorebook: Scorebook) {
        self.scorebook = scorebook
        let defaults = UserDefaults.standard
        cutButton = defaults.object(forKey: "cutButton") as? Bool ?? (UIDevice.current.userInterfaceIdiom == .pad)
        turnFold = defaults.bool(forKey: "turnFold")
    }

    var isFolded: Bool { posture == .closed }

    func play(_ level: Level) {
        level.thing.prepare()
        self.level = level
        cut = nil
        // Start off to one side, so you always have to line it up.
        dragged = CGPoint(x: level.number % 2 == 0 ? -1.1 : 1.1, y: 0)
        swingStart = Double.random(in: 0..<(2 * .pi))
        screen = .play
        if posture == .open || cutButton {
            show()
        } else {
            phase = .waitingToOpen
        }
    }

    func retry() { play(level) }

    var nextLevel: Level? {
        level.isDaily ? nil : Level.find(level.number + 1)
    }

    func leave() {
        screen = level.isDaily ? .menu : .levels
        phase = .waitingToOpen
        cut = nil
    }

    /// Turns on the CUT button when the phone can't fold, and starts right away.
    func useCutButton() {
        cutButton = true
        if screen == .play && phase == .waitingToOpen { show() }
    }

    private func show() {
        phase = .aiming
        shownAt = Date()
    }

    /// Where the object is and how it's turned right now.
    func pose(at date: Date) -> (offset: CGPoint, turn: Double) {
        level.pose(at: date.timeIntervalSince(shownAt), dragged: dragged, swingStart: swingStart)
    }

    /// Folding is the knife: open -> closed cuts, closed -> open shows the scale.
    func postureChanged(to new: Posture) {
        let old = posture
        posture = new
        guard screen == .play, old != new else { return }
        switch (phase, new) {
        case (.waitingToOpen, .open):
            show()
        case (.aiming, .closed):
            // A fold in the first moment is probably the phone still settling.
            if Date().timeIntervalSince(shownAt) > 0.6 {
                chop(byFold: true)
            } else if !cutButton {
                phase = .waitingToOpen
            }
        case (.chopped, .open):
            reveal()
        default:
            break
        }
    }

    func chop(byFold: Bool) {
        guard phase == .aiming else { return }
        let now = pose(at: Date())
        let thing = level.thing
        let share = thing.leftShare(offset: now.offset.x, turn: now.turn)
        let error = abs(share - 0.5) * 100
        cut = Cut(offset: now.offset, turn: now.turn, leftShare: share,
                  perfectOffset: thing.perfectOffset(turn: now.turn),
                  reach: thing.reach(turn: now.turn), stars: level.stars(error: error))
        phase = .chopped
        choppedAt = Date()
        Haptics.chop()
        if !byFold {
            Task { [weak self] in
                try? await Task.sleep(for: .seconds(0.9))
                if self?.phase == .chopped { self?.reveal() }
            }
        }
    }

    private func reveal() {
        guard let cut else { return }
        phase = .result
        revealedAt = Date()
        scorebook.record(level, error: cut.error, stars: cut.stars)
    }
}
