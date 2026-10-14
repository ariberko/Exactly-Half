import SwiftUI

/// Pick how many players and rounds, then pass the phone around.
struct PartySetupView: View {
    @ObservedObject var game: Game
    @EnvironmentObject private var store: Store
    @Environment(\.dismiss) private var dismiss
    @State private var players = 2
    @State private var rounds = 3

    var body: some View {
        NavigationStack {
            VStack(spacing: 26) {
                Image(systemName: "person.3.fill")
                    .font(.system(size: 44))
                    .foregroundStyle(Theme.gold)
                Text("Everyone cuts the same objects. The smallest total miss wins.")
                    .font(Theme.body(16))
                    .foregroundStyle(.white.opacity(0.8))
                    .multilineTextAlignment(.center)

                picker("PLAYERS", options: [2, 3, 4], value: $players)
                picker("ROUNDS", options: [3, 5, 7], value: $rounds)

                NeonButton(title: "START PARTY", color: Theme.gold) {
                    game.startParty(players: players, rounds: rounds, ownsFullGame: store.owns(StoreIDs.fullGame))
                    dismiss()
                }
                if !store.owns(StoreIDs.fullGame) {
                    Text("Party uses mystery objects and your free levels. The Full Game adds every level.")
                        .font(Theme.body(13))
                        .foregroundStyle(.white.opacity(0.5))
                        .multilineTextAlignment(.center)
                }
                Spacer()
            }
            .padding(24)
            .frame(maxWidth: .infinity)
            .background(Theme.background.ignoresSafeArea())
            .navigationTitle("Party")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }

    private func picker(_ title: String, options: [Int], value: Binding<Int>) -> some View {
        VStack(spacing: 8) {
            Text(title).font(Theme.title(14)).foregroundStyle(.white.opacity(0.5))
            HStack(spacing: 10) {
                ForEach(options, id: \.self) { option in
                    Button {
                        value.wrappedValue = option
                    } label: {
                        Text("\(option)")
                            .font(Theme.title(22))
                            .foregroundStyle(value.wrappedValue == option ? Color.black : .white)
                            .frame(width: 60, height: 50)
                            .background(value.wrappedValue == option ? Theme.gold : Color.white.opacity(0.08),
                                        in: RoundedRectangle(cornerRadius: 14))
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}

/// "Pass the phone to Player 2."
struct HandOffView: View {
    @ObservedObject var game: Game
    let party: Party

    var body: some View {
        let color = Party.colors[party.turn]
        VStack(spacing: 16) {
            Spacer()
            Text("ROUND \(party.round + 1) OF \(party.levels.count)")
                .font(Theme.title(15))
                .foregroundStyle(.white.opacity(0.55))
            Text("PLAYER \(party.turn + 1)")
                .font(Theme.title(56))
                .foregroundStyle(color)
                .shadow(color: color, radius: 16)
            Text(party.turn == 0 ? "You go first!" : "Pass the phone to Player \(party.turn + 1)")
                .font(Theme.body(17, weight: .semibold))
                .foregroundStyle(.white.opacity(0.8))
            Text(game.level.name)
                .font(Theme.title(22))
                .foregroundStyle(.white)
            NeonButton(title: "I'M READY", color: color) { game.ready() }
            Spacer()
            Button("Stop party") { game.leave() }
                .font(Theme.body(15, weight: .semibold))
                .foregroundStyle(.white.opacity(0.6))
                .padding(.bottom, 24)
        }
        .padding(24)
    }
}

/// The winner and everyone's total miss.
struct PartyOverView: View {
    @ObservedObject var game: Game
    let party: Party
    @EnvironmentObject private var store: Store

    var body: some View {
        let order = party.standings
        let winner = order.first ?? 0
        ScrollView {
            VStack(spacing: 18) {
                Image(systemName: "crown.fill")
                    .font(.system(size: 50))
                    .foregroundStyle(Theme.gold)
                    .shadow(color: Theme.gold, radius: 14)
                Text("PLAYER \(winner + 1) WINS!")
                    .font(Theme.title(38))
                    .foregroundStyle(Party.colors[winner])
                    .minimumScaleFactor(0.5)
                    .lineLimit(1)
                VStack(spacing: 10) {
                    ForEach(Array(order.enumerated()), id: \.element) { place, player in
                        HStack {
                            Text("\(place + 1).").font(Theme.title(20)).foregroundStyle(.white.opacity(0.5))
                            Text("Player \(player + 1)").font(Theme.title(20)).foregroundStyle(Party.colors[player])
                            Spacer()
                            Text("off by \(ResultView.precise(party.totals[player]))")
                                .font(Theme.title(17))
                                .monospacedDigit()
                                .foregroundStyle(.white)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(.white.opacity(place == 0 ? 0.12 : 0.05), in: RoundedRectangle(cornerRadius: 14))
                    }
                }
                .frame(maxWidth: 420)
                NeonButton(title: "PLAY AGAIN", color: Theme.gold) {
                    game.partyAgain(ownsFullGame: store.owns(StoreIDs.fullGame))
                }
                NeonButton(title: "MENU", color: .white.opacity(0.8), small: true) { game.leave() }
            }
            .padding(24)
            .frame(maxWidth: .infinity)
        }
        .onAppear { Sounds.play(.win) }
    }
}
