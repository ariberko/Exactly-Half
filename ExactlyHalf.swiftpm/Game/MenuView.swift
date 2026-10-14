import SwiftUI

/// The start screen.
struct MenuView: View {
    @ObservedObject var game: Game
    let posture: Posture
    let openShop: () -> Void
    let openSettings: () -> Void

    @EnvironmentObject private var store: Store
    @EnvironmentObject private var scorebook: Scorebook
    @State private var showingParty = false

    var body: some View {
        GeometryReader { geo in
            ScrollView {
                VStack(spacing: 20) {
                    Logo(size: 54)

                    HStack(spacing: 8) {
                        Image(systemName: posture == .open ? "rectangle.split.2x1" : "iphone")
                        Text(posture == .open ? "Open - ready to cut" : "Closed - open it to play")
                    }
                    .font(Theme.body(15, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.75))
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(.white.opacity(0.08), in: Capsule())

                    NeonButton(title: "PLAY") { playNext() }
                    HStack(spacing: 12) {
                        NeonButton(title: "LEVELS", color: Theme.halves[1], small: true) { game.screen = .levels }
                        NeonButton(title: "PARTY", color: Theme.gold, small: true) { showingParty = true }
                    }

                    dailyCard

                    HStack(spacing: 12) {
                        smallButton("SHOP", symbol: "bag.fill", color: Theme.gold, action: openShop)
                        smallButton("SETTINGS", symbol: "gearshape.fill", color: .white.opacity(0.8), action: openSettings)
                    }

                    Text("★ \(scorebook.totalStars) of \(Level.all.count * 3)")
                        .font(Theme.title(15))
                        .foregroundStyle(.white.opacity(0.55))
                }
                .padding(24)
                // Centered when it fits, scrollable when the screen is short (tent mode).
                .frame(maxWidth: .infinity, minHeight: geo.size.height)
            }
            .scrollBounceBehavior(.basedOnSize)
        }
        .onAppear { scorebook.refreshDaily() }
        .sheet(isPresented: $showingParty) {
            PartySetupView(game: game)
        }
    }

    private func playNext() {
        let number = scorebook.nextLevel
        if let level = Level.find(number), scorebook.isOpen(level, ownsFullGame: store.owns(StoreIDs.fullGame)) {
            game.play(level)
        } else if !store.owns(StoreIDs.fullGame) {
            openShop()
        } else {
            game.screen = .levels
        }
    }

    private var dailyCard: some View {
        Button {
            game.play(.daily())
        } label: {
            HStack(spacing: 14) {
                Image(systemName: "calendar")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(Theme.gold)
                    .frame(width: 44, height: 44)
                    .background(Theme.gold.opacity(0.15), in: RoundedRectangle(cornerRadius: 12))
                VStack(alignment: .leading, spacing: 2) {
                    Text("DAILY CUT").font(Theme.title(17)).foregroundStyle(.white)
                    Text(dailyDetail)
                        .font(Theme.body(13))
                        .foregroundStyle(.white.opacity(0.6))
                }
                Spacer()
                if scorebook.streak > 0 {
                    Text("🔥 \(scorebook.streak)").font(Theme.title(17)).foregroundStyle(.white)
                }
            }
            .padding(12)
            .frame(maxWidth: 360)
            .background(.white.opacity(0.06), in: RoundedRectangle(cornerRadius: 16))
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(Theme.gold.opacity(0.4), lineWidth: 1))
        }
        .buttonStyle(.plain)
    }

    private var dailyDetail: String {
        if let best = scorebook.dailyBest {
            return "Today's best: off by \(ResultView.precise(best))"
        }
        return "A new mystery object every day. Free!"
    }

    private func smallButton(_ title: String, symbol: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Label(title, systemImage: symbol)
                .font(Theme.title(15))
                .foregroundStyle(color)
                .padding(.horizontal, 16)
                .padding(.vertical, 9)
                .overlay(Capsule().stroke(color.opacity(0.7), lineWidth: 1.5))
        }
        .buttonStyle(.plain)
    }
}

/// Every level, grouped in chapters, with stars and locks.
struct LevelMapView: View {
    @ObservedObject var game: Game
    let openShop: () -> Void

    @EnvironmentObject private var store: Store
    @EnvironmentObject private var scorebook: Scorebook

    private let columns = [GridItem(.adaptive(minimum: 64), spacing: 12)]

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Button {
                    game.screen = .menu
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(width: 40, height: 40)
                        .background(.white.opacity(0.12), in: Circle())
                }
                .buttonStyle(.plain)
                Spacer()
                Text("LEVELS").font(Theme.title(22)).foregroundStyle(.white)
                Spacer()
                Text("★ \(scorebook.totalStars)")
                    .font(Theme.title(16))
                    .foregroundStyle(Theme.gold)
                    .frame(width: 60, alignment: .trailing)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)

            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    if !store.owns(StoreIDs.fullGame) {
                        unlockCard
                    }
                    ForEach(Array(Level.chapters.enumerated()), id: \.offset) { index, chapter in
                        let last = index + 1 < Level.chapters.count ? Level.chapters[index + 1].first - 1 : Level.all.count
                        VStack(alignment: .leading, spacing: 10) {
                            HStack {
                                Text(chapter.name.uppercased())
                                    .font(Theme.title(15))
                                    .foregroundStyle(.white.opacity(0.55))
                                if index == 0 {
                                    Text("FREE")
                                        .font(Theme.title(11))
                                        .foregroundStyle(.black)
                                        .padding(.horizontal, 6)
                                        .padding(.vertical, 2)
                                        .background(Theme.good, in: Capsule())
                                }
                            }
                            LazyVGrid(columns: columns, spacing: 12) {
                                ForEach(Level.all.filter { $0.number >= chapter.first && $0.number <= last }) { level in
                                    bubble(level)
                                }
                            }
                        }
                    }
                }
                .padding(16)
            }
        }
    }

    private var unlockCard: some View {
        Button(action: openShop) {
            HStack(spacing: 12) {
                Image(systemName: "lock.open.fill").font(.system(size: 22))
                VStack(alignment: .leading, spacing: 2) {
                    Text("FULL GAME").font(Theme.title(17))
                    Text("Unlock all \(Level.all.count - Level.freeCount) extra levels and Master Chef.")
                        .font(Theme.body(13))
                        .foregroundStyle(.white.opacity(0.7))
                }
                Spacer()
                Image(systemName: "chevron.right")
            }
            .foregroundStyle(Theme.gold)
            .padding(14)
            .background(Theme.gold.opacity(0.1), in: RoundedRectangle(cornerRadius: 16))
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(Theme.gold.opacity(0.5), lineWidth: 1.5))
        }
        .buttonStyle(.plain)
    }

    private func bubble(_ level: Level) -> some View {
        let owns = store.owns(StoreIDs.fullGame)
        let open = scorebook.isOpen(level, ownsFullGame: owns)
        let paid = !level.isFree && !owns
        let stars = scorebook.stars(for: level.number)
        return Button {
            if open {
                game.play(level)
            } else if paid {
                openShop()
            } else {
                Haptics.ouch()
            }
        } label: {
            VStack(spacing: 4) {
                ZStack {
                    Circle()
                        .fill(open ? Theme.halves[stars > 0 ? 0 : 1].opacity(0.9) : .white.opacity(0.08))
                    if open {
                        Text("\(level.number)").font(Theme.title(22)).foregroundStyle(.black)
                    } else {
                        Image(systemName: paid ? "crown.fill" : "lock.fill")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundStyle(paid ? Theme.gold : .white.opacity(0.4))
                    }
                }
                .frame(width: 56, height: 56)
                StarsView(count: stars, size: 10)
            }
        }
        .buttonStyle(.plain)
    }
}

/// A couple of switches for phones and iPads that can't fold, or fold the other way.
struct SettingsView: View {
    @ObservedObject var game: Game
    @Environment(\.dismiss) private var dismiss
    @AppStorage("sounds") private var sounds = true

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Toggle("Sounds", isOn: $sounds)
                } footer: {
                    Text("The silent switch also mutes them.")
                }
                Section {
                    Toggle("Show a CUT button", isOn: $game.cutButton)
                } footer: {
                    Text("For phones and iPads that can't fold. On an iPhone Duo you cut by folding the phone.")
                }
                Section {
                    Toggle("Turn the cut line", isOn: $game.turnFold)
                } footer: {
                    Text("If the line on screen doesn't sit on your hinge, turn this on.")
                }
                Section("How to play") {
                    Label("Open your iPhone Duo. The line down the middle is the hinge.", systemImage: "rectangle.split.2x1")
                    Label("Drag the object until you think the line cuts it into two equal weights.", systemImage: "hand.draw")
                    Label("Fold the phone closed to chop. Open it again to see the scale.", systemImage: "scalemass")
                    Label("Heavy parts count more than big parts!", systemImage: "lightbulb")
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}
