import SwiftUI

/// Stars for every level and the Daily Cut streak. Saved on the phone.
@MainActor
final class Scorebook: ObservableObject {
    @Published private(set) var stars: [Int: Int]
    @Published private(set) var dailyBest: Double?
    @Published private(set) var streak: Int

    private let defaults = UserDefaults.standard

    init() {
        let saved = defaults.dictionary(forKey: "stars") as? [String: Int] ?? [:]
        stars = Dictionary(uniqueKeysWithValues: saved.compactMap { key, value in Int(key).map { ($0, value) } })
        streak = defaults.integer(forKey: "streak")
        dailyBest = nil
        refreshDaily()
    }

    func stars(for level: Int) -> Int { stars[level] ?? 0 }

    var totalStars: Int { stars.values.reduce(0, +) }

    /// A level can be played once the one before it has at least one star.
    /// Levels past the free ones also need the Full Game.
    func isOpen(_ level: Level, ownsFullGame: Bool) -> Bool {
        if level.isDaily { return true }
        if !level.isFree && !ownsFullGame { return false }
        return level.number == 1 || stars(for: level.number - 1) > 0
    }

    /// The first level without a star, so PLAY picks up where you left off.
    var nextLevel: Int {
        Level.all.first { stars(for: $0.number) == 0 }?.number ?? Level.all.count
    }

    func record(_ level: Level, error: Double, stars earned: Int) {
        if level.isDaily {
            recordDaily(error: error, passed: earned > 0)
            return
        }
        guard earned > stars(for: level.number) else { return }
        stars[level.number] = earned
        defaults.set(Dictionary(uniqueKeysWithValues: stars.map { (String($0.key), $0.value) }), forKey: "stars")
    }

    // MARK: - Daily Cut

    /// Forgets yesterday's best and a broken streak.
    func refreshDaily(now: Date = Date()) {
        let today = DayKey.from(now)
        dailyBest = defaults.integer(forKey: "dailyDay") == today ? defaults.double(forKey: "dailyBest") : nil
        let last = defaults.integer(forKey: "streakDay")
        if last != today && last != DayKey.yesterday(of: now) && streak != 0 {
            streak = 0
            defaults.set(0, forKey: "streak")
        }
    }

    private func recordDaily(error: Double, passed: Bool, now: Date = Date()) {
        let today = DayKey.from(now)
        if dailyBest.map({ error < $0 }) ?? true {
            dailyBest = error
            defaults.set(today, forKey: "dailyDay")
            defaults.set(error, forKey: "dailyBest")
        }
        guard passed else { return }
        let last = defaults.integer(forKey: "streakDay")
        if last == today { return }
        streak = last == DayKey.yesterday(of: now) ? streak + 1 : 1
        defaults.set(streak, forKey: "streak")
        defaults.set(today, forKey: "streakDay")
    }
}
