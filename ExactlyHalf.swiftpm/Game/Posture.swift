import CoreGraphics

/// How the iPhone Duo is being held, guessed from the screen's shape.
/// Apple asks apps to use the screen size instead of asking "is it folded?",
/// so a big, almost square screen means "open" and anything else means "closed or tent".
enum Posture {
    case closed
    case open

    init(size: CGSize) {
        let short = min(size.width, size.height)
        let long = max(size.width, size.height)
        self = short >= 560 && short / max(long, 1) > 0.68 ? .open : .closed
    }
}

/// Where the hinge is on the open screen. The game is worked out as if the
/// hinge were always a straight up-and-down line, then turned to match the screen.
struct FoldFrame {
    let screen: CGSize
    /// True when the hinge runs top to bottom on the screen.
    let upright: Bool

    /// The hinge splits the long side of the open screen in two (like a book).
    /// `turned` flips it, for phones that fold the other way.
    init(screen: CGSize, turned: Bool) {
        self.screen = screen
        upright = (screen.width >= screen.height) != turned
    }

    /// The game's own size: the hinge is the line x = width / 2.
    var size: CGSize {
        upright ? screen : CGSize(width: screen.height, height: screen.width)
    }

    /// Maps the game's own space onto the screen.
    var toScreen: CGAffineTransform {
        upright ? .identity : CGAffineTransform(a: 0, b: 1, c: -1, d: 0, tx: screen.width, ty: 0)
    }

    /// Turns a finger movement on the screen into a movement in the game's own space.
    func fromScreen(_ move: CGSize) -> CGSize {
        upright ? move : CGSize(width: move.height, height: -move.width)
    }
}
