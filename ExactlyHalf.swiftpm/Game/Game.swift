import SwiftUI
import UIKit

enum Screen { case menu, levels, play }

/// One go at a level:
/// (handOff ->) waitingToOpen -> aiming -> (fold) chopped -> (open) result (-> partyOver).
enum Phase { case handOff, waitingToOpen, aiming, chopped, result, partyOver }

/// What happened when the blade came down.
struct Cut {
    let offset: CGPoint
    let turn: Double
    /// Share of the weight left of the cut (0...1).
    let leftShare: Double
    /// Where the object should have been for a perfect cut.
    let perfectOffset: Double
    let reach: (left: Double, right: Double, top: Double, bottom: Double)
    /// The share the left piece should have had.
    let target: Double
    let stars: Int

    /// How far from the goal (50/50 on most levels), in percent.
    var error: Double { abs(leftShare - target) * 100 }
}

/// Party mode: friends take turns cutting the same objects. Lowest total miss wins.
struct Party {
    static let colors = [Theme.halves[0], Theme.halves[1], Theme.gold, Theme.good]

    let players: Int
    let levels: [Level]
    /// Every player gets the same start each round, so it's fair.
    let starts: [Double]
    let swings: [Double]
    var round = 0
    var turn = 0
    /// misses[player][round], in percent.
    var misses: [[Double]]

    init(players: Int, levels: [Level]) {
        self.players = players
        self.levels = levels
        starts = levels.map { _ in Bool.random() ? 1.1 : -1.1 }
        swings = levels.map { _ in Double.random(in: 0..<(2 * .pi)) }
        misses = Array(repeating: [], count: players)
    }

    var totals: [Double] { misses.map { $0.reduce(0, +) } }
    var isLastTurnOfRound: Bool { turn == players - 1 }
    var isLastTurn: Bool { isLastTurnOfRound && round == levels.count - 1 }

    /// Player numbers from best to worst.
    var standings: [Int] { totals.indices.sorted { totals[$0] < totals[$1] } }
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
    @Published private(set) var party: Party?

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
        party = nil
        // Start off to one side, so you always have to line it up.
        load(level, start: level.number % 2 == 0 ? -1.1 : 1.1, swing: Double.random(in: 0..<(2 * .pi)))
        ready()
    }

    private func load(_ level: Level, start: Double, swing: Double) {
        level.thing.prepare()
        self.level = level
        cut = nil
        dragged = CGPoint(x: start, y: 0)
        swingStart = swing
        screen = .play
    }

    /// Shows the object, or asks to open the phone first.
    func ready() {
        if posture == .open || cutButton {
            show()
        } else {
            phase = .waitingToOpen
        }
    }

    func retry() { play(level) }

    var nextLevel: Level? {
        level.isDaily || level.number == 0 ? nil : Level.find(level.number + 1)
    }

    func leave() {
        screen = level.isDaily || party != nil ? .menu : .levels
        phase = .waitingToOpen
        party = nil
        cut = nil
    }

    // MARK: - Party

    /// Mystery objects for everyone, plus the real levels you've unlocked.
    func startParty(players: Int, rounds: Int, ownsFullGame: Bool) {
        let unlocked = Level.all.filter { ownsFullGame || $0.isFree }
        var levels: [Level] = []
        for round in 0..<rounds {
            if round % 2 == 1, let pick = unlocked.randomElement() {
                levels.append(pick)
            } else {
                levels.append(.mystery(seed: UInt64.random(in: 1...UInt64.max)))
            }
        }
        party = Party(players: players, levels: levels)
        beginTurn()
    }

    private func beginTurn() {
        guard let party else { return }
        load(party.levels[party.round], start: party.starts[party.round], swing: party.swings[party.round])
        phase = .handOff
    }

    /// After a party turn: the next player, the next round, or the winner.
    func nextTurn() {
        guard var party else { return }
        party.turn += 1
        if party.turn == party.players {
            party.turn = 0
            party.round += 1
        }
        self.party = party
        if party.round >= party.levels.count {
            cut = nil
            phase = .partyOver
        } else {
            beginTurn()
        }
    }

    func partyAgain(ownsFullGame: Bool) {
        guard let party else { return }
        startParty(players: party.players, rounds: party.levels.count, ownsFullGame: ownsFullGame)
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
        let error = abs(share - level.target) * 100
        cut = Cut(offset: now.offset, turn: now.turn, leftShare: share,
                  perfectOffset: thing.perfectOffset(turn: now.turn, share: level.target),
                  reach: thing.reach(turn: now.turn), target: level.target, stars: level.stars(error: error))
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
        if var party {
            party.misses[party.turn].append(cut.error)
            self.party = party
        } else {
            scorebook.record(level, error: cut.error, stars: cut.stars)
        }
    }
}
