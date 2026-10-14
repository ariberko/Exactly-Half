import SwiftUI

@main
struct ExactlyHalfApp: App {
    @StateObject private var store = Store()
    @StateObject private var scorebook: Scorebook
    @StateObject private var game: Game

    init() {
        let scorebook = Scorebook()
        _scorebook = StateObject(wrappedValue: scorebook)
        _game = StateObject(wrappedValue: Game(scorebook: scorebook))
    }

    var body: some Scene {
        WindowGroup {
            RootView(game: game)
                .environmentObject(store)
                .environmentObject(scorebook)
                .preferredColorScheme(.dark)
        }
    }
}
