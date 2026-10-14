import SwiftUI

/// Picks the screen and watches the phone fold and unfold.
struct RootView: View {
    @ObservedObject var game: Game
    @EnvironmentObject private var store: Store
    @AppStorage("blade") private var bladeID = Blade.classic.id
    @State private var showingShop = false
    @State private var showingSettings = false

    /// The chosen blade, or Classic if it isn't owned (for example after a refund).
    private var blade: Blade {
        let chosen = Blade.with(id: bladeID)
        return store.owns(chosen) ? chosen : .classic
    }

    var body: some View {
        GeometryReader { geo in
            let posture = Posture(size: geo.size)
            ZStack {
                Theme.background

                switch game.screen {
                case .menu:
                    MenuView(game: game, posture: posture,
                             openShop: { showingShop = true }, openSettings: { showingSettings = true })
                case .levels:
                    LevelMapView(game: game, openShop: { showingShop = true })
                        .padding(.top, max(geo.safeAreaInsets.top, 8))
                case .play:
                    PlayView(game: game, blade: blade, openShop: { showingShop = true })
                }
            }
            .onAppear { game.postureChanged(to: posture) }
            .onChange(of: geo.size) { _, size in game.postureChanged(to: Posture(size: size)) }
        }
        .ignoresSafeArea()
        .statusBarHidden()
        .persistentSystemOverlays(.hidden)
        .defersSystemGestures(on: .all)
        .sheet(isPresented: $showingShop) {
            ShopView()
        }
        .sheet(isPresented: $showingSettings) {
            SettingsView(game: game)
        }
    }
}
