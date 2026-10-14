import StoreKit
import SwiftUI

/// The shop: the Full Game, the Blade Pack, All Access and a tip jar.
struct ShopView: View {
    @EnvironmentObject private var store: Store
    @Environment(\.dismiss) private var dismiss
    @AppStorage("blade") private var bladeID = Blade.classic.id
    @State private var buying: String?

    private let columns = [GridItem(.adaptive(minimum: 150), spacing: 14)]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 26) {
                    if !store.hasEverything {
                        allAccessCard
                    }

                    section("MORE GAME") {
                        unlockRow(id: StoreIDs.fullGame, title: "Full Game",
                                  detail: "\(Level.all.count - Level.freeCount) more levels: wobbly, moving and vanishing objects, Master Chef and Fractions.",
                                  symbol: "square.grid.3x3.fill")
                    }

                    section("BLADES") {
                        LazyVGrid(columns: columns, spacing: 14) {
                            ForEach(Blade.all) { blade in bladeCard(blade) }
                        }
                        if !store.owns(StoreIDs.blades) {
                            unlockRow(id: StoreIDs.blades, title: "Blade Pack",
                                      detail: "Laser, Katana, Chainsaw and Plasma.", symbol: "scissors")
                        }
                    }

                    section("TIP JAR") {
                        Text("Made by one person. Tips keep new levels coming.")
                            .font(Theme.body(14))
                            .foregroundStyle(.white.opacity(0.6))
                        HStack(spacing: 12) {
                            tipButton(StoreIDs.tipSmall, emoji: "☕️")
                            tipButton(StoreIDs.tipBig, emoji: "🍕")
                        }
                    }

                    Button {
                        Task { await store.restore() }
                    } label: {
                        HStack {
                            Text("Restore Purchases")
                            if store.isRestoring { ProgressView().tint(.white) }
                        }
                        .font(Theme.body(15, weight: .semibold))
                        .foregroundStyle(.white.opacity(0.7))
                        .frame(maxWidth: .infinity)
                    }
                    .disabled(store.isRestoring)

                    if store.products.isEmpty && !store.isLoading {
                        Text("Prices couldn't load. Check your internet and open the shop again.")
                            .font(.footnote)
                            .foregroundStyle(.white.opacity(0.5))
                            .frame(maxWidth: .infinity)
                    }
                }
                .padding(20)
            }
            .background(Theme.background.ignoresSafeArea())
            .navigationTitle("Shop")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
        .task {
            if store.products.isEmpty { await store.loadProducts() }
            await store.refreshEntitlements()
        }
        .alert("Shop", isPresented: Binding(
            get: { store.message != nil },
            set: { if !$0 { store.message = nil } }
        )) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(store.message ?? "")
        }
    }

    // MARK: - Pieces

    private func section<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(Theme.title(15))
                .foregroundStyle(.white.opacity(0.5))
            content()
        }
    }

    private var allAccessCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: "star.circle.fill").font(.system(size: 30))
                Text("ALL ACCESS").font(Theme.title(26))
            }
            .foregroundStyle(Theme.gold)
            Text("The Full Game and every blade. Plus everything added later.")
                .font(Theme.body(15))
                .foregroundStyle(.white.opacity(0.8))
            priceButton(StoreIDs.allAccess, color: Theme.gold)
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.white.opacity(0.06))
                .overlay(RoundedRectangle(cornerRadius: 20).stroke(Theme.gold.opacity(0.6), lineWidth: 1.5))
        )
    }

    private func bladeCard(_ blade: Blade) -> some View {
        let owned = store.owns(blade)
        let inUse = bladeID == blade.id
        return VStack(alignment: .leading, spacing: 8) {
            Canvas { context, size in
                context.fill(Path(CGRect(origin: .zero, size: size)), with: .color(.black.opacity(0.35)))
                blade.draw(in: context, x: size.width / 2, height: size.height)
            }
            .frame(height: 80)
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .overlay(RoundedRectangle(cornerRadius: 14).stroke(inUse ? blade.color : .clear, lineWidth: 3))
            Text(blade.name).font(Theme.title(17)).foregroundStyle(.white)
            Text(blade.tagline)
                .font(Theme.body(12))
                .foregroundStyle(.white.opacity(0.6))
                .lineLimit(2, reservesSpace: true)
            Button {
                if owned { bladeID = blade.id }
            } label: {
                Text(inUse ? "IN USE" : owned ? "USE" : "LOCKED")
                    .font(Theme.title(14))
                    .foregroundStyle(inUse || !owned ? Color.white.opacity(0.6) : Color.black)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(inUse || !owned ? Color.white.opacity(0.1) : blade.color, in: Capsule())
            }
            .buttonStyle(.plain)
            .disabled(inUse || !owned)
        }
    }

    private func unlockRow(id: String, title: String, detail: String, symbol: String) -> some View {
        HStack(spacing: 14) {
            Image(systemName: symbol)
                .font(.system(size: 22))
                .foregroundStyle(Theme.halves[0])
                .frame(width: 44, height: 44)
                .background(.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 12))
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(Theme.title(17)).foregroundStyle(.white)
                Text(detail).font(Theme.body(13)).foregroundStyle(.white.opacity(0.6))
            }
            Spacer()
            if store.owns(id) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 24))
                    .foregroundStyle(Theme.good)
            } else {
                priceButton(id, color: Theme.halves[0]).frame(width: 90)
            }
        }
    }

    private func tipButton(_ id: String, emoji: String) -> some View {
        Button {
            buy(id)
        } label: {
            VStack(spacing: 4) {
                Text(emoji).font(.system(size: 30))
                Text(store.product(id)?.displayPrice ?? "...")
                    .font(Theme.title(15))
                    .foregroundStyle(.white)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 14))
        }
        .buttonStyle(.plain)
        .disabled(store.product(id) == nil || buying != nil)
    }

    private func priceButton(_ id: String, color: Color) -> some View {
        Button {
            buy(id)
        } label: {
            Group {
                if buying == id {
                    ProgressView().tint(.black)
                } else {
                    Text(store.product(id)?.displayPrice ?? "...")
                }
            }
            .font(Theme.title(15))
            .foregroundStyle(.black)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .background(color, in: Capsule())
        }
        .buttonStyle(.plain)
        .disabled(store.product(id) == nil || buying != nil)
    }

    private func buy(_ id: String) {
        guard let product = store.product(id) else { return }
        buying = id
        Task {
            await store.buy(product)
            buying = nil
            // Try a new blade right after buying the pack.
            if (id == StoreIDs.blades || id == StoreIDs.allAccess) && store.owns(StoreIDs.blades) && bladeID == Blade.classic.id {
                bladeID = Blade.laser.id
            }
        }
    }
}
