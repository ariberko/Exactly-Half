// Made by scripts/levels.py - change the levels there, then run it again.

import Foundation

extension Thing {
    static let baguette = Thing(name: "Baguette", parts: [
        .capsule(-0.95, 0, 0.95, 0, 0.22, weight: 0.3, color: 0xD9A05B),
        .rect(-0.6, -0.02, 0.06, 0.3, corner: 0.03, turn: 35, color: 0xF3D29B, role: .deco),
        .rect(-0.3, -0.02, 0.06, 0.3, corner: 0.03, turn: 35, color: 0xF3D29B, role: .deco),
        .rect(0, -0.02, 0.06, 0.3, corner: 0.03, turn: 35, color: 0xF3D29B, role: .deco),
        .rect(0.3, -0.02, 0.06, 0.3, corner: 0.03, turn: 35, color: 0xF3D29B, role: .deco),
        .rect(0.6, -0.02, 0.06, 0.3, corner: 0.03, turn: 35, color: 0xF3D29B, role: .deco),
    ])
    static let cheese = Thing(name: "Cheese Wedge", parts: [
        .poly([(-0.9, -0.6), (-0.9, 0.5), (0.95, 0.5)], weight: 1, color: 0xF7C948),
        .ellipse(-0.6, 0.2, 0.09, 0.09, color: 0xE0A82E, role: .deco),
        .ellipse(-0.35, 0.33, 0.06, 0.06, color: 0xE0A82E, role: .deco),
        .ellipse(-0.7, -0.2, 0.05, 0.05, color: 0xE0A82E, role: .deco),
    ])
    static let carrot = Thing(name: "Carrot", parts: [
        .poly([(-0.62, -0.26), (0.95, -0.02), (0.95, 0.02), (-0.62, 0.26)], weight: 1, color: 0xF28C28),
        .ellipse(-0.62, 0, 0.06, 0.26, weight: 1, color: 0xF28C28),
        .poly([(-0.62, -0.08), (-0.98, -0.42), (-0.9, -0.05)], weight: 0.15, color: 0x4CAF50),
        .poly([(-0.62, 0), (-1, 0), (-0.9, -0.15)], weight: 0.15, color: 0x66BB6A),
        .poly([(-0.62, 0.08), (-0.98, 0.42), (-0.9, 0.05)], weight: 0.15, color: 0x4CAF50),
        .rect(-0.3, 0, 0.02, 0.19, color: 0xD9731C, role: .deco),
        .rect(0.05, 0, 0.02, 0.155, color: 0xD9731C, role: .deco),
        .rect(0.4, 0, 0.02, 0.12, color: 0xD9731C, role: .deco),
    ])
    static let banana = Thing(name: "Banana", parts: [
        .poly([(0.94, -0.472), (0.891, -0.333), (0.829, -0.201), (0.755, -0.08), (0.669, 0.029), (0.574, 0.124), (0.469, 0.204), (0.358, 0.267), (0.242, 0.313), (0.122, 0.341), (0, 0.35), (-0.122, 0.341), (-0.242, 0.313), (-0.358, 0.267), (-0.469, 0.204), (-0.574, 0.124), (-0.669, 0.029), (-0.755, -0.08), (-0.829, -0.201), (-0.891, -0.333), (-0.94, -0.472), (-0.77, -0.591), (-0.725, -0.506), (-0.67, -0.427), (-0.606, -0.354), (-0.535, -0.289), (-0.457, -0.233), (-0.373, -0.186), (-0.284, -0.149), (-0.191, -0.122), (-0.096, -0.105), (0, -0.1), (0.096, -0.105), (0.191, -0.122), (0.284, -0.149), (0.373, -0.186), (0.457, -0.233), (0.535, -0.289), (0.606, -0.354), (0.67, -0.427), (0.725, -0.506), (0.77, -0.591)], weight: 1, color: 0xF9D84A),
        .capsule(-0.95, -0.32, -0.88, -0.25, 0.05, color: 0x6D4C2F, role: .deco),
        .capsule(0.88, -0.25, 0.95, -0.32, 0.04, color: 0x6D4C2F, role: .deco),
    ])
    static let lollipop = Thing(name: "Lollipop", parts: [
        .rect(-0.35, 0, 1.25, 0.08, corner: 0.04, weight: 0.25, color: 0xF5F5F5),
        .ellipse(0.52, 0, 0.42, 0.42, weight: 1.5, color: 0xFF4F9A),
        .ellipse(0.52, 0, 0.3, 0.3, color: 0xFF8DC2, role: .deco),
        .ellipse(0.52, 0, 0.17, 0.17, color: 0xFF4F9A, role: .deco),
        .ellipse(0.52, 0, 0.06, 0.06, color: 0xFFFFFF, role: .deco),
    ])
    static let hammer = Thing(name: "Hammer", parts: [
        .rect(-0.2, 0, 1.5, 0.17, corner: 0.06, weight: 0.7, color: 0xB07A45),
        .rect(0.7, 0, 0.26, 0.85, corner: 0.04, weight: 6, color: 0x9AA5B1),
        .rect(0.72, -0.34, 0.34, 0.1, corner: 0.03, weight: 6, color: 0x9AA5B1),
        .rect(-0.8, 0, 0.3, 0.19, corner: 0.06, color: 0x2E2E2E, role: .deco),
    ])
    static let icecream = Thing(name: "Ice Cream", parts: [
        .poly([(-0.95, 0), (0.2, -0.36), (0.2, 0.36)], weight: 0.35, color: 0xD9A05B),
        .capsule(-0.6, -0.2, -0.4, 0.2, 0.012, color: 0xB57D3C, role: .deco),
        .capsule(-0.4, -0.18, -0.2, 0.18, 0.012, color: 0xB57D3C, role: .deco),
        .capsule(-0.2, -0.16, 0, 0.16, 0.012, color: 0xB57D3C, role: .deco),
        .capsule(0, -0.14, 0.2, 0.14, 0.012, color: 0xB57D3C, role: .deco),
        .ellipse(0.5, 0, 0.43, 0.46, weight: 1, color: 0xFFB3C7),
        .ellipse(0.2, 0, 0.12, 0.42, weight: 1, color: 0xFFB3C7),
        .ellipse(0.9, -0.1, 0.1, 0.1, weight: 1.2, color: 0xE53935),
    ])
    static let fish = Thing(name: "Fish", parts: [
        .poly([(-0.98, -0.42), (-0.52, 0), (-0.98, 0.42)], weight: 0.5, color: 0x4FC3F7),
        .ellipse(0.15, 0, 0.75, 0.4, weight: 1, color: 0x29B6F6),
        .ellipse(0.6, -0.08, 0.07, 0.07, color: 0xFFFFFF, role: .deco),
        .ellipse(0.62, -0.08, 0.035, 0.035, color: 0x0D1B2A, role: .deco),
        .poly([(0.341, -0.282), (0.367, -0.249), (0.389, -0.201), (0.406, -0.141), (0.416, -0.073), (0.42, 0), (0.416, 0.073), (0.406, 0.141), (0.389, 0.201), (0.367, 0.249), (0.341, 0.282)], color: 0x0288D1, role: .deco),
    ])
    static let pizza = Thing(name: "Pizza Slice", parts: [
        .poly([(-0.95, 0), (0.78, -0.62), (0.78, 0.62)], weight: 1, color: 0xFFCA62),
        .capsule(0.82, -0.62, 0.82, 0.62, 0.13, weight: 1.8, color: 0xC98B3D),
        .ellipse(-0.3, 0.02, 0.1, 0.1, color: 0xD84315, role: .deco),
        .ellipse(0.15, -0.25, 0.1, 0.1, color: 0xD84315, role: .deco),
        .ellipse(0.3, 0.25, 0.1, 0.1, color: 0xD84315, role: .deco),
        .ellipse(0.5, -0.05, 0.1, 0.1, color: 0xD84315, role: .deco),
    ])
    static let spoon = Thing(name: "Spoon", parts: [
        .capsule(-0.95, 0, 0.3, 0, 0.07, weight: 1, color: 0xCFD8DC),
        .ellipse(0.6, 0, 0.36, 0.25, weight: 1, color: 0xCFD8DC),
        .ellipse(0.6, 0, 0.28, 0.18, color: 0xB0BEC5, role: .deco),
    ])
    static let mushroom = Thing(name: "Mushroom", parts: [
        .rect(-0.45, 0, 0.95, 0.4, corner: 0.1, weight: 0.6, color: 0xF5E6CC),
        .poly([(0.05, -0.85), (0.134, -0.845), (0.216, -0.831), (0.297, -0.808), (0.375, -0.777), (0.45, -0.736), (0.52, -0.688), (0.585, -0.632), (0.645, -0.569), (0.697, -0.5), (0.743, -0.425), (0.781, -0.346), (0.811, -0.263), (0.833, -0.177), (0.846, -0.089), (0.85, 0), (0.846, 0.089), (0.833, 0.177), (0.811, 0.263), (0.781, 0.346), (0.743, 0.425), (0.697, 0.5), (0.645, 0.569), (0.585, 0.632), (0.52, 0.688), (0.45, 0.736), (0.375, 0.777), (0.297, 0.808), (0.216, 0.831), (0.134, 0.845), (0.05, 0.85)], weight: 0.9, color: 0xE53935),
        .ellipse(0.4, -0.3, 0.1, 0.1, color: 0xFFFFFF, role: .deco),
        .ellipse(0.55, 0.2, 0.08, 0.08, color: 0xFFFFFF, role: .deco),
        .ellipse(0.25, 0.45, 0.07, 0.07, color: 0xFFFFFF, role: .deco),
        .ellipse(0.2, -0.6, 0.06, 0.06, color: 0xFFFFFF, role: .deco),
    ])
    static let drumstick = Thing(name: "Drumstick", parts: [
        .capsule(-0.9, 0, 0.1, 0, 0.08, weight: 1.9, color: 0xF5F5F5),
        .ellipse(-0.92, -0.1, 0.1, 0.1, weight: 1.9, color: 0xF5F5F5),
        .ellipse(-0.92, 0.1, 0.1, 0.1, weight: 1.9, color: 0xF5F5F5),
        .ellipse(0.38, 0, 0.6, 0.42, weight: 1.05, color: 0xC8783C),
        .ellipse(0.5, -0.12, 0.25, 0.12, turn: -15, color: 0xDA9150, role: .deco),
    ])
    static let pin = Thing(name: "Bowling Pin", parts: [
        .ellipse(-0.35, 0, 0.62, 0.42, weight: 1, color: 0xF5F5F5),
        .rect(0.38, 0, 0.4, 0.2, weight: 1, color: 0xF5F5F5),
        .ellipse(0.72, 0, 0.24, 0.22, weight: 1, color: 0xF5F5F5),
        .rect(0.38, 0, 0.06, 0.2, color: 0xE53935, role: .deco),
        .rect(0.48, 0, 0.06, 0.21, color: 0xE53935, role: .deco),
    ])
    static let guitar = Thing(name: "Guitar", parts: [
        .ellipse(-0.55, 0, 0.42, 0.47, weight: 0.7, color: 0xD4823B),
        .ellipse(-0.05, 0, 0.32, 0.35, weight: 0.7, color: 0xD4823B),
        .ellipse(-0.25, 0, 0.12, 0.12, color: 0x000000, role: .hole),
        .rect(0.5, 0, 0.9, 0.12, weight: 0.9, color: 0x6D4C2F),
        .rect(0.9, 0, 0.16, 0.2, corner: 0.03, weight: 0.9, color: 0x4E342E),
        .rect(-0.78, 0, 0.06, 0.3, color: 0x4E342E, role: .deco),
    ])
    static let swiss = Thing(name: "Swiss Cheese", parts: [
        .rect(0, 0, 1.9, 1.1, corner: 0.05, weight: 1, color: 0xFBD25B),
        .ellipse(0.55, -0.15, 0.25, 0.22, color: 0x000000, role: .hole),
        .ellipse(0.3, 0.3, 0.15, 0.13, color: 0x000000, role: .hole),
        .ellipse(0.75, 0.32, 0.12, 0.12, color: 0x000000, role: .hole),
        .ellipse(-0.5, -0.25, 0.1, 0.1, color: 0x000000, role: .hole),
        .ellipse(0.05, -0.3, 0.12, 0.14, color: 0x000000, role: .hole),
    ])
    static let sausage = Thing(name: "Sausage", parts: [
        .capsule(-0.9, 0.05, 0.9, 0.05, 0.2, weight: 1, color: 0xB5523B),
        .capsule(-0.7, -0.05, 0.7, -0.05, 0.04, color: 0xD47A5E, role: .deco),
        .ellipse(-0.98, 0.05, 0.05, 0.04, color: 0x8E3B2A, role: .deco),
        .ellipse(0.98, 0.05, 0.05, 0.04, color: 0x8E3B2A, role: .deco),
    ])
    static let pear = Thing(name: "Pear", parts: [
        .ellipse(-0.35, 0, 0.55, 0.55, weight: 1, color: 0xA5D65B),
        .ellipse(0.35, 0, 0.38, 0.33, weight: 1, color: 0xA5D65B),
        .rect(0.82, 0, 0.2, 0.05, weight: 0.5, color: 0x6D4C2F),
        .poly([(0.82, -0.02), (0.95, -0.22), (0.7, -0.12)], weight: 0.2, color: 0x4CAF50),
    ])
    static let key = Thing(name: "Key", parts: [
        .ellipse(-0.65, 0, 0.32, 0.32, weight: 6, color: 0xFFC83D),
        .ellipse(-0.68, 0, 0.13, 0.13, color: 0x000000, role: .hole),
        .rect(0.15, 0, 1.4, 0.13, corner: 0.05, weight: 6, color: 0xFFC83D),
        .rect(0.62, 0.13, 0.08, 0.16, weight: 6, color: 0xFFC83D),
        .rect(0.78, 0.15, 0.08, 0.22, weight: 6, color: 0xFFC83D),
        .rect(0.9, 0.12, 0.06, 0.14, weight: 6, color: 0xFFC83D),
    ])
    static let racket = Thing(name: "Tennis Racket", parts: [
        .capsule(-0.95, 0, -0.3, 0, 0.07, weight: 1.2, color: 0x37474F),
        .ellipse(0.38, 0, 0.58, 0.45, weight: 1.4, color: 0x26C6DA),
        .ellipse(0.38, 0, 0.5, 0.37, weight: 0.12, color: 0xE0F7FA),
        .rect(0.02, 0, 0.01, 0.5, color: 0x80DEEA, role: .deco),
        .rect(0.14, 0, 0.01, 0.632, color: 0x80DEEA, role: .deco),
        .rect(0.26, 0, 0.01, 0.699, color: 0x80DEEA, role: .deco),
        .rect(0.38, 0, 0.01, 0.72, color: 0x80DEEA, role: .deco),
        .rect(0.5, 0, 0.01, 0.699, color: 0x80DEEA, role: .deco),
        .rect(0.62, 0, 0.01, 0.632, color: 0x80DEEA, role: .deco),
        .rect(0.74, 0, 0.01, 0.5, color: 0x80DEEA, role: .deco),
        .rect(0.38, -0.24, 0.746, 0.01, color: 0x80DEEA, role: .deco),
        .rect(0.38, -0.12, 0.927, 0.01, color: 0x80DEEA, role: .deco),
        .rect(0.38, 0, 0.98, 0.01, color: 0x80DEEA, role: .deco),
        .rect(0.38, 0.12, 0.927, 0.01, color: 0x80DEEA, role: .deco),
        .rect(0.38, 0.24, 0.746, 0.01, color: 0x80DEEA, role: .deco),
    ])
    static let rocket = Thing(name: "Rocket", parts: [
        .poly([(-0.75, -0.42), (-0.5, -0.2), (-0.5, 0.2), (-0.75, 0.42), (-0.85, 0.42), (-0.6, 0), (-0.85, -0.42)], weight: 1.2, color: 0xE53935),
        .capsule(-0.6, 0, 0.45, 0, 0.22, weight: 0.6, color: 0xECEFF1),
        .poly([(0.45, -0.22), (0.95, 0), (0.45, 0.22)], weight: 1.5, color: 0xE53935),
        .ellipse(0.15, 0, 0.09, 0.09, color: 0x4FC3F7, role: .deco),
        .poly([(-0.82, -0.12), (-1, 0), (-0.82, 0.12)], color: 0xFFB300, role: .deco),
    ])
    static let dumbbell = Thing(name: "Dumbbell", parts: [
        .rect(0, 0, 1.6, 0.1, weight: 6, color: 0x90A4AE),
        .rect(-0.72, 0, 0.22, 0.9, corner: 0.05, weight: 6, color: 0x37474F),
        .rect(-0.5, 0, 0.12, 0.7, corner: 0.04, weight: 6, color: 0x455A64),
        .rect(0.72, 0, 0.16, 0.6, corner: 0.05, weight: 6, color: 0x37474F),
    ])
    static let axe = Thing(name: "Axe", parts: [
        .rect(-0.2, 0, 1.55, 0.12, corner: 0.05, weight: 0.7, color: 0xB07A45),
        .poly([(0.45, -0.1), (0.62, -0.12), (0.95, -0.55), (0.98, 0.5), (0.62, 0.12), (0.45, 0.1)], weight: 6, color: 0x90A4AE),
        .poly([(0.88, -0.45), (0.95, -0.5), (0.97, 0.45), (0.9, 0.4)], color: 0xCFD8DC, role: .deco),
    ])
    static let bottle = Thing(name: "Juice Bottle", parts: [
        .rect(-0.25, 0, 1.3, 0.62, corner: 0.15, weight: 2.5, color: 0xA5D6A7),
        .rect(-0.25, 0, 1.2, 0.52, corner: 0.12, weight: 0.02, color: 0x17202C),
        .rect(-0.48, 0, 0.74, 0.52, corner: 0.1, weight: 1, color: 0xFF9800),
        .rect(0.6, 0, 0.42, 0.24, corner: 0.05, weight: 2.5, color: 0xA5D6A7),
        .rect(0.6, 0, 0.42, 0.14, weight: 0.02, color: 0x17202C),
        .rect(0.86, 0, 0.12, 0.28, corner: 0.03, weight: 1, color: 0xE53935),
    ])
    static let snowman = Thing(name: "Snowman", parts: [
        .ellipse(-0.55, 0, 0.42, 0.42, weight: 0.4, color: 0xF5F5F5),
        .ellipse(0.08, 0, 0.3, 0.3, weight: 0.4, color: 0xF5F5F5),
        .ellipse(0.5, 0, 0.2, 0.2, weight: 0.4, color: 0xF5F5F5),
        .rect(0.78, 0, 0.14, 0.38, weight: 1, color: 0x263238),
        .rect(0.9, 0, 0.18, 0.22, weight: 1, color: 0x263238),
        .poly([(0.5, -0.04), (0.52, 0.04), (0.42, 0.26)], color: 0xFF9800, role: .deco),
        .ellipse(-0.3, 0, 0.035, 0.035, color: 0x263238, role: .deco),
        .ellipse(-0.05, 0, 0.035, 0.035, color: 0x263238, role: .deco),
        .ellipse(0.12, 0, 0.035, 0.035, color: 0x263238, role: .deco),
    ])
    static let umbrella = Thing(name: "Umbrella", parts: [
        .poly([(0.1, -0.95), (0.165, -0.945), (0.229, -0.929), (0.292, -0.904), (0.352, -0.868), (0.41, -0.823), (0.464, -0.769), (0.515, -0.706), (0.561, -0.636), (0.602, -0.558), (0.637, -0.475), (0.666, -0.386), (0.69, -0.294), (0.706, -0.198), (0.717, -0.099), (0.72, 0), (0.717, 0.099), (0.706, 0.198), (0.69, 0.294), (0.666, 0.386), (0.637, 0.475), (0.602, 0.558), (0.561, 0.636), (0.515, 0.706), (0.464, 0.769), (0.41, 0.823), (0.352, 0.868), (0.292, 0.904), (0.229, 0.929), (0.165, 0.945), (0.1, 0.95)], weight: 0.3, color: 0x7E57C2),
        .poly([(0.1, 0), (0.1, -0.95), (0.292, -0.904)], color: 0x9575CD, role: .deco),
        .poly([(0.1, 0), (0.602, -0.558), (0.69, -0.294)], color: 0x9575CD, role: .deco),
        .poly([(0.1, 0), (0.69, 0.294), (0.602, 0.558)], color: 0x9575CD, role: .deco),
        .poly([(0.1, 0), (0.292, 0.904), (0.1, 0.95)], color: 0x9575CD, role: .deco),
        .rect(-0.4, 0, 1, 0.07, weight: 6, color: 0x455A64),
        .poly([(-0.9, 0), (-0.939, 0.004), (-0.977, 0.015), (-1.011, 0.034), (-1.041, 0.059), (-1.066, 0.089), (-1.085, 0.123), (-1.096, 0.161), (-1.1, 0.2), (-1.096, 0.239), (-1.085, 0.277), (-1.066, 0.311), (-1.041, 0.341), (-1.011, 0.366), (-0.977, 0.385), (-0.939, 0.396), (-0.9, 0.4), (-0.9, 0.33), (-0.925, 0.328), (-0.95, 0.32), (-0.972, 0.308), (-0.992, 0.292), (-1.008, 0.272), (-1.02, 0.25), (-1.028, 0.225), (-1.03, 0.2), (-1.028, 0.175), (-1.02, 0.15), (-1.008, 0.128), (-0.992, 0.108), (-0.972, 0.092), (-0.95, 0.08), (-0.925, 0.072), (-0.9, 0.07)], weight: 6, color: 0x455A64),
    ])
    static let boot = Thing(name: "Boot", parts: [
        .poly([(-0.9, -0.6), (-0.2, -0.6), (-0.2, 0.1), (0.85, 0.15), (0.95, 0.4), (0.9, 0.55), (-0.9, 0.55)], weight: 0.8, color: 0x8D6E63),
        .rect(-0.65, 0.6, 0.5, 0.18, corner: 0.04, weight: 2.2, color: 0x3E2723),
        .rect(0.3, 0.6, 1.2, 0.08, weight: 1.2, color: 0x3E2723),
        .rect(-0.55, -0.45, 0.7, 0.1, color: 0x6D4C41, role: .deco),
    ])
    static let wrench = Thing(name: "Wrench", parts: [
        .ellipse(-0.68, 0, 0.3, 0.3, weight: 6, color: 0xB0BEC5),
        .poly([(-0.56, 0), (-0.62, 0.104), (-0.74, 0.104), (-0.8, 0), (-0.74, -0.104), (-0.62, -0.104)], color: 0x000000, role: .hole),
        .rect(0.05, 0, 1.2, 0.18, corner: 0.06, weight: 6, color: 0xB0BEC5),
        .ellipse(0.7, 0, 0.32, 0.42, weight: 6, color: 0xB0BEC5),
        .rect(0.86, 0, 0.3, 0.18, color: 0x000000, role: .hole),
    ])
    static let golf = Thing(name: "Golf Club", parts: [
        .capsule(-0.95, -0.05, 0.6, -0.05, 0.035, weight: 1, color: 0xB0BEC5),
        .capsule(-0.95, -0.05, -0.55, -0.05, 0.06, weight: 0.8, color: 0x212121),
        .poly([(0.55, -0.12), (0.78, -0.15), (0.98, 0.25), (0.88, 0.42), (0.55, 0.3)], weight: 6, color: 0x78909C),
    ])
    static let trophy = Thing(name: "Trophy", parts: [
        .rect(-0.82, 0, 0.22, 0.8, corner: 0.04, weight: 3, color: 0x6D4C41),
        .rect(-0.25, 0, 0.95, 0.12, weight: 2, color: 0xFFC107),
        .ellipse(-0.2, 0, 0.09, 0.16, weight: 2, color: 0xFFC107),
        .poly([(0.85, 0.62), (0.764, 0.615), (0.679, 0.599), (0.597, 0.573), (0.52, 0.537), (0.448, 0.492), (0.383, 0.438), (0.326, 0.377), (0.278, 0.31), (0.24, 0.237), (0.212, 0.16), (0.196, 0.081), (0.19, 0), (0.196, -0.081), (0.212, -0.16), (0.24, -0.237), (0.278, -0.31), (0.326, -0.377), (0.383, -0.438), (0.448, -0.492), (0.52, -0.537), (0.597, -0.573), (0.679, -0.599), (0.764, -0.615), (0.85, -0.62)], weight: 2, color: 0xFFC107),
        .poly([(0.9, 0.52), (0.827, 0.516), (0.755, 0.502), (0.686, 0.48), (0.62, 0.45), (0.559, 0.413), (0.504, 0.368), (0.456, 0.317), (0.415, 0.26), (0.383, 0.199), (0.359, 0.135), (0.345, 0.068), (0.34, 0), (0.345, -0.068), (0.359, -0.135), (0.383, -0.199), (0.415, -0.26), (0.456, -0.317), (0.504, -0.368), (0.559, -0.413), (0.62, -0.45), (0.686, -0.48), (0.755, -0.502), (0.827, -0.516), (0.9, -0.52)], color: 0x000000, role: .hole),
        .rect(0.84, 0, 0.03, 1.22, color: 0xFFE082, role: .deco),
    ])
    static let sailboat = Thing(name: "Sailboat", parts: [
        .poly([(-0.95, 0.3), (-0.95, -0.3), (-0.6, -0.55), (-0.6, 0.55)], weight: 2, color: 0x8D6E63),
        .rect(0.15, 0, 1.5, 0.05, weight: 0.7, color: 0x5D4037),
        .poly([(-0.55, 0.02), (0.9, 0.02), (-0.55, 0.65)], weight: 0.1, color: 0xFFFFFF),
        .poly([(-0.55, -0.02), (0.7, -0.02), (-0.55, -0.5)], weight: 0.1, color: 0xFFEB3B),
    ])
    static let cactus = Thing(name: "Cactus", parts: [
        .rect(-0.15, 0, 1.6, 0.36, corner: 0.18, weight: 0.9, color: 0x43A047),
        .rect(-0.05, -0.32, 0.18, 0.4, corner: 0.09, weight: 0.9, color: 0x43A047),
        .rect(0.2, -0.55, 0.5, 0.18, corner: 0.09, weight: 0.9, color: 0x43A047),
        .rect(-0.35, 0.32, 0.18, 0.4, corner: 0.09, weight: 0.9, color: 0x43A047),
        .rect(-0.55, 0.55, 0.5, 0.18, corner: 0.09, weight: 0.9, color: 0x43A047),
        .poly([(-0.95, -0.3), (-0.95, 0.3), (-0.75, 0.25), (-0.75, -0.25)], weight: 2.5, color: 0xD84315),
    ])
    static let bulb = Thing(name: "Light Bulb", parts: [
        .ellipse(0.25, 0, 0.62, 0.62, weight: 0.15, color: 0xFFF59D),
        .rect(-0.45, 0, 0.3, 0.42, weight: 0.15, color: 0xFFF59D),
        .rect(-0.68, 0, 0.32, 0.42, corner: 0.04, weight: 4, color: 0x9E9E9E),
        .rect(-0.88, 0, 0.12, 0.22, corner: 0.04, weight: 4, color: 0x616161),
        .poly([(-0.3, -0.1), (0.2, -0.15), (0.2, 0.15), (-0.3, 0.1)], color: 0xFFB300, role: .deco),
    ])
    static let egg = Thing(name: "Golden Egg", parts: [
        .poly([(0.95, 0), (0.942, 0.073), (0.918, 0.145), (0.878, 0.217), (0.823, 0.287), (0.754, 0.355), (0.672, 0.42), (0.578, 0.48), (0.475, 0.536), (0.364, 0.585), (0.246, 0.626), (0.124, 0.658), (0, 0.68), (-0.124, 0.69), (-0.246, 0.687), (-0.364, 0.672), (-0.475, 0.642), (-0.578, 0.599), (-0.672, 0.542), (-0.754, 0.473), (-0.823, 0.393), (-0.878, 0.303), (-0.918, 0.207), (-0.942, 0.105), (-0.95, 0), (-0.942, -0.105), (-0.918, -0.207), (-0.878, -0.303), (-0.823, -0.393), (-0.754, -0.473), (-0.672, -0.542), (-0.578, -0.599), (-0.475, -0.642), (-0.364, -0.672), (-0.246, -0.687), (-0.124, -0.69), (0, -0.68), (0.124, -0.658), (0.246, -0.626), (0.364, -0.585), (0.475, -0.536), (0.578, -0.48), (0.672, -0.42), (0.754, -0.355), (0.823, -0.287), (0.878, -0.217), (0.918, -0.145), (0.942, -0.073)], weight: 1.2, color: 0xFFD54F),
        .ellipse(-0.22, 0.05, 0.38, 0.36, weight: 3, color: 0xFFB300),
        .ellipse(0.25, -0.3, 0.18, 0.08, turn: -20, color: 0xFFF8E1, role: .deco),
    ])
}

extension Level {
    static let all: [Level] = [
        Level(number: 1, thing: .baguette, tolerance: 5, tip: "Drag the bread so the line cuts it in the middle. Then fold your phone!"),
        Level(number: 2, thing: .cheese, tolerance: 4, tip: "Careful: the fat end has more cheese than the pointy end."),
        Level(number: 3, thing: .carrot, tolerance: 4, tip: "The leaves are light. The orange part is heavy."),
        Level(number: 4, thing: .banana, tolerance: 3, turn: 35, tip: "Banana bends. Half the banana is not half the box."),
        Level(number: 5, thing: .lollipop, tolerance: 3, tip: "Candy is heavy. The stick weighs almost nothing."),
        Level(number: 6, thing: .hammer, tolerance: 3, tip: "Steel is 8 times heavier than wood!"),
        Level(number: 7, thing: .icecream, tolerance: 3, tip: "The scoop is heavier than the cone."),
        Level(number: 8, thing: .fish, tolerance: 3, turn: 12, tip: "The tail is thin and light."),
        Level(number: 9, thing: .pizza, tolerance: 3, tip: "The crust is the heaviest part."),
        Level(number: 10, thing: .spoon, tolerance: 2.5, wobble: 12, period: 3.2, tip: "It's wobbling! Fold when it's the right way."),
        Level(number: 11, thing: .mushroom, tolerance: 2.5, wobble: 15, period: 3, tip: "The cap is big but light and fluffy."),
        Level(number: 12, thing: .drumstick, tolerance: 2.5, wobble: 18, period: 2.8, tip: "Bone is heavier than meat."),
        Level(number: 13, thing: .pin, tolerance: 2.5, wobble: 20, period: 2.6, tip: "Bowling pins are fat at the bottom."),
        Level(number: 14, thing: .guitar, tolerance: 2.5, wobble: 22, period: 2.6, tip: "Mind the hole in the middle!"),
        Level(number: 15, thing: .swiss, tolerance: 2.5, wobble: 25, period: 2.4, tip: "Holes weigh nothing. Look where they are."),
        Level(number: 16, thing: .sausage, tolerance: 3, move: 0.8, period: 3.6, tip: "It won't hold still! Fold at just the right moment."),
        Level(number: 17, thing: .pear, tolerance: 3, move: 0.8, period: 3.4, tip: "Wait for the fat part to pass the line."),
        Level(number: 18, thing: .key, tolerance: 3, move: 0.8, period: 3.2, tip: "The ring has a hole. The teeth are tiny."),
        Level(number: 19, thing: .racket, tolerance: 3, turn: -10, move: 0.9, period: 3, tip: "Strings are light. The frame is not."),
        Level(number: 20, thing: .rocket, tolerance: 3, move: 0.9, period: 2.8, tip: "The red parts are heavy metal."),
        Level(number: 21, thing: .dumbbell, tolerance: 3, move: 1, period: 2.6, tip: "One side has more weights."),
        Level(number: 22, thing: .axe, tolerance: 2.5, hide: .silhouette, tip: "Look fast! The colors go away in 3 seconds."),
        Level(number: 23, thing: .bottle, tolerance: 2.5, hide: .silhouette, tip: "Remember where the juice is."),
        Level(number: 24, thing: .snowman, tolerance: 2.5, turn: 8, hide: .silhouette, tip: "The hat is heavy. Snow is light."),
        Level(number: 25, thing: .umbrella, tolerance: 2.5, hide: .vanish, tip: "It disappears! Remember where it was."),
        Level(number: 26, thing: .boot, tolerance: 2.5, turn: -6, hide: .vanish, tip: "The heel is the heaviest part."),
        Level(number: 27, thing: .wrench, tolerance: 2.5, hide: .vanish, tip: "Two holes. Remember them."),
        Level(number: 28, thing: .golf, tolerance: 2, wobble: 10, move: 0.7, period: 3, tip: "Moving AND wobbling. Good luck!"),
        Level(number: 29, thing: .trophy, tolerance: 2, wobble: 15, period: 2.8, hide: .silhouette, tip: "The wood base is heavy."),
        Level(number: 30, thing: .sailboat, tolerance: 2, move: 0.8, period: 3, hide: .silhouette, tip: "Sails are paper light."),
        Level(number: 31, thing: .cactus, tolerance: 1.5, turn: 15, wobble: 20, period: 2.2, tip: "The pot is heavy clay."),
        Level(number: 32, thing: .bulb, tolerance: 1.5, wobble: 12, period: 2.6, hide: .vanish, tip: "Glass is thin. The metal base is heavy."),
        Level(number: 33, thing: .egg, tolerance: 1, wobble: 12, move: 0.7, period: 2.6, hide: .silhouette, tip: "The final boss. The gold yolk is heavy!"),
    ]

    static let chapters: [(first: Int, name: String)] = [
        (1, "Easy Cuts"),
        (4, "Kitchen Classics"),
        (10, "Wobbly"),
        (16, "On the Move"),
        (22, "Now You See It"),
        (28, "Master Chef"),
    ]
}
