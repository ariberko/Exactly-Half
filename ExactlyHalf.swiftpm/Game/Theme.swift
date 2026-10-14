import SwiftUI

enum Theme {
    static let background = LinearGradient(
        colors: [Color(red: 0.04, green: 0.03, blue: 0.12), Color(red: 0.10, green: 0.02, blue: 0.18)],
        startPoint: .top, endPoint: .bottom
    )
    /// The left half and the right half.
    static let halves = [Color(red: 0.2, green: 0.9, blue: 1.0), Color(red: 1.0, green: 0.3, blue: 0.75)]
    static let gold = Color(red: 1.0, green: 0.82, blue: 0.25)
    static let good = Color(red: 0.35, green: 0.95, blue: 0.45)
    static let silhouette = Color(white: 0.62)

    static func title(_ size: CGFloat) -> Font {
        .system(size: size, weight: .black, design: .rounded)
    }

    static func body(_ size: CGFloat, weight: Font.Weight = .regular) -> Font {
        .system(size: size, weight: weight, design: .rounded)
    }
}

/// A big glowing button.
struct NeonButton: View {
    let title: String
    var color: Color = Theme.halves[0]
    var small = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(Theme.title(small ? 17 : 22))
                .foregroundStyle(.black)
                .frame(minWidth: small ? 140 : 220)
                .padding(.vertical, small ? 10 : 14)
                .background(color, in: Capsule())
                .shadow(color: color.opacity(0.8), radius: 12)
        }
        .buttonStyle(.plain)
    }
}

/// A row of stars, filled up to `count`.
struct StarsView: View {
    let count: Int
    var size: CGFloat = 14

    var body: some View {
        HStack(spacing: size * 0.15) {
            ForEach(0..<3, id: \.self) { i in
                Image(systemName: i < count ? "star.fill" : "star")
                    .foregroundStyle(i < count ? Theme.gold : .white.opacity(0.25))
            }
        }
        .font(.system(size: size, weight: .bold))
    }
}

/// The "EXACTLY HALF" logo, with HALF split down the middle.
struct Logo: View {
    var size: CGFloat = 52

    var body: some View {
        VStack(spacing: 0) {
            Text("EXACTLY")
                .font(Theme.title(size * 0.55))
                .foregroundStyle(.white)
                .shadow(color: .white.opacity(0.5), radius: 8)
            ZStack {
                Text("HALF").foregroundStyle(Theme.halves[1])
                    .mask(HStack(spacing: 0) { Color.clear; Color.black })
                    .offset(x: size * 0.06, y: size * 0.04)
                Text("HALF").foregroundStyle(Theme.halves[0])
                    .mask(HStack(spacing: 0) { Color.black; Color.clear })
                    .offset(x: -size * 0.06, y: -size * 0.04)
            }
            .font(Theme.title(size))
            .shadow(color: Theme.halves[0].opacity(0.6), radius: 12)
        }
        .lineLimit(1)
        .minimumScaleFactor(0.5)
    }
}
