"""The one place where every Exactly Half object and level is made.

Run:  python3 scripts/levels.py [preview.png]
It writes ExactlyHalf.swiftpm/Game/LevelData.swift and, if you give a file
name, draws a picture of every object with its perfect cut line in red.

Objects live in a box from -1 to 1 (x to the right, y down). The cut is a
straight up-and-down line. Parts are painted in order: a later part covers
an earlier one, both on screen and on the scale.
  solid - has weight (density)
  deco  - only paint, no weight
  hole  - cuts a see-through hole, no weight
"""
import math
import sys

HERE = __file__.rsplit("/", 2)[0] if "/" in __file__ else "."
OUT = f"{HERE}/ExactlyHalf.swiftpm/Game/LevelData.swift"

# Weights (density). Water is 1.
WOOD, STEEL, GLASS, SNOW, CANDY, BREAD = 0.7, 6.0, 2.5, 0.4, 1.5, 0.3


def E(cx, cy, rx, ry, d, c, a=0, role="solid"):
    return dict(kind="ellipse", cx=cx, cy=cy, rx=rx, ry=ry, a=a, d=d, c=c, role=role)


def R(cx, cy, w, h, d, c, corner=0, a=0, role="solid"):
    return dict(kind="rect", cx=cx, cy=cy, w=w, h=h, corner=corner, a=a, d=d, c=c, role=role)


def P(points, d, c, role="solid"):
    return dict(kind="poly", pts=[(round(x, 3), round(y, 3)) for x, y in points], d=d, c=c, role=role)


def C(x1, y1, x2, y2, r, d, c, role="solid"):
    return dict(kind="capsule", x1=x1, y1=y1, x2=x2, y2=y2, r=r, d=d, c=c, role=role)


def deco(part):
    return {**part, "role": "deco", "d": 0}


def hole(part):
    return {**part, "role": "hole", "d": 0, "c": "000000"}


def arc(cx, cy, rx, ry, a0, a1, n=24):
    """Points on an ellipse from angle a0 to a1 (degrees)."""
    return [(cx + rx * math.cos(math.radians(a0 + (a1 - a0) * i / n)),
             cy + ry * math.sin(math.radians(a0 + (a1 - a0) * i / n))) for i in range(n + 1)]


def egg(cx, cy, length, width, n=48):
    """An egg lying down, fat end on the left."""
    pts = []
    for i in range(n):
        t = 2 * math.pi * i / n
        x = math.cos(t)
        y = math.sin(t) * (1 - 0.18 * x)
        pts.append((cx + x * length, cy + y * width))
    return pts


def crescent(n=20):
    """A banana: an outer arc and an inner arc."""
    outer = arc(0, -0.9, 1.0, 1.25, 20, 160, n)
    inner = arc(0, -0.95, 0.85, 0.85, 155, 25, n)
    return outer + inner


# ---------------------------------------------------------------- objects

THINGS = {}


def thing(key, name, *parts):
    THINGS[key] = dict(name=name, parts=list(parts))


thing("baguette", "Baguette",
      C(-0.95, 0, 0.95, 0, 0.22, BREAD, "D9A05B"),
      *[deco(R(x, -0.02, 0.06, 0.3, 0, "F3D29B", corner=0.03, a=35)) for x in (-0.6, -0.3, 0, 0.3, 0.6)])

thing("cheese", "Cheese Wedge",
      P([(-0.9, -0.6), (-0.9, 0.5), (0.95, 0.5)], 1, "F7C948"),
      deco(E(-0.6, 0.2, 0.09, 0.09, 0, "E0A82E")),
      deco(E(-0.35, 0.33, 0.06, 0.06, 0, "E0A82E")),
      deco(E(-0.7, -0.2, 0.05, 0.05, 0, "E0A82E")))

thing("carrot", "Carrot",
      P([(-0.62, -0.26), (0.95, -0.02), (0.95, 0.02), (-0.62, 0.26)], 1, "F28C28"),
      E(-0.62, 0, 0.06, 0.26, 1, "F28C28"),
      P([(-0.62, -0.08), (-0.98, -0.42), (-0.9, -0.05)], 0.15, "4CAF50"),
      P([(-0.62, 0.0), (-1.0, 0.0), (-0.9, -0.15)], 0.15, "66BB6A"),
      P([(-0.62, 0.08), (-0.98, 0.42), (-0.9, 0.05)], 0.15, "4CAF50"),
      *[deco(R(x, 0, 0.02, 0.22 - (x + 0.6) * 0.1, 0, "D9731C")) for x in (-0.3, 0.05, 0.4)])

thing("banana", "Banana",
      P(crescent(), 1, "F9D84A"),
      deco(C(-0.95, -0.32, -0.88, -0.25, 0.05, 0, "6D4C2F")),
      deco(C(0.88, -0.25, 0.95, -0.32, 0.04, 0, "6D4C2F")))

thing("lollipop", "Lollipop",
      R(-0.35, 0, 1.25, 0.08, 0.25, "F5F5F5", corner=0.04),
      E(0.52, 0, 0.42, 0.42, CANDY, "FF4F9A"),
      deco(E(0.52, 0, 0.3, 0.3, 0, "FF8DC2")),
      deco(E(0.52, 0, 0.17, 0.17, 0, "FF4F9A")),
      deco(E(0.52, 0, 0.06, 0.06, 0, "FFFFFF")))

thing("hammer", "Hammer",
      R(-0.2, 0, 1.5, 0.17, WOOD, "B07A45", corner=0.06),
      R(0.7, 0, 0.26, 0.85, STEEL, "9AA5B1", corner=0.04),
      R(0.72, -0.34, 0.34, 0.1, STEEL, "9AA5B1", corner=0.03),
      deco(R(-0.8, 0, 0.3, 0.19, 0, "2E2E2E", corner=0.06)))

thing("icecream", "Ice Cream",
      P([(-0.95, 0), (0.2, -0.36), (0.2, 0.36)], 0.35, "D9A05B"),
      *[deco(C(-0.6 + i * 0.2, -0.2 + i * 0.02, -0.4 + i * 0.2, 0.2 - i * 0.02, 0.012, 0, "B57D3C")) for i in range(4)],
      E(0.5, 0, 0.43, 0.46, 1, "FFB3C7"),
      E(0.2, 0, 0.12, 0.42, 1, "FFB3C7"),
      E(0.9, -0.1, 0.1, 0.1, 1.2, "E53935"))

thing("fish", "Fish",
      P([(-0.98, -0.42), (-0.52, 0), (-0.98, 0.42)], 0.5, "4FC3F7"),
      E(0.15, 0, 0.75, 0.4, 1, "29B6F6"),
      deco(E(0.6, -0.08, 0.07, 0.07, 0, "FFFFFF")),
      deco(E(0.62, -0.08, 0.035, 0.035, 0, "0D1B2A")),
      deco(P(arc(0.3, 0, 0.12, 0.3, -70, 70, 10), 0, "0288D1")))

thing("pizza", "Pizza Slice",
      P([(-0.95, 0), (0.78, -0.62), (0.78, 0.62)], 1, "FFCA62"),
      C(0.82, -0.62, 0.82, 0.62, 0.13, 1.8, "C98B3D"),
      *[deco(E(x, y, 0.1, 0.1, 0, "D84315")) for x, y in ((-0.3, 0.02), (0.15, -0.25), (0.3, 0.25), (0.5, -0.05))])

thing("spoon", "Spoon",
      C(-0.95, 0, 0.3, 0, 0.07, 1, "CFD8DC"),
      E(0.6, 0, 0.36, 0.25, 1, "CFD8DC"),
      deco(E(0.6, 0, 0.28, 0.18, 0, "B0BEC5")))

thing("mushroom", "Mushroom",
      R(-0.45, 0, 0.95, 0.4, 0.6, "F5E6CC", corner=0.1),
      P(arc(0.05, 0, 0.8, 0.85, -90, 90, 30), 0.9, "E53935"),
      *[deco(E(x, y, r, r, 0, "FFFFFF")) for x, y, r in ((0.4, -0.3, 0.1), (0.55, 0.2, 0.08), (0.25, 0.45, 0.07), (0.2, -0.6, 0.06))])

thing("drumstick", "Drumstick",
      C(-0.9, 0, 0.1, 0, 0.08, 1.9, "F5F5F5"),
      E(-0.92, -0.1, 0.1, 0.1, 1.9, "F5F5F5"),
      E(-0.92, 0.1, 0.1, 0.1, 1.9, "F5F5F5"),
      E(0.38, 0, 0.6, 0.42, 1.05, "C8783C"),
      deco(E(0.5, -0.12, 0.25, 0.12, 0, "DA9150", a=-15)))

thing("pin", "Bowling Pin",
      E(-0.35, 0, 0.62, 0.42, 1, "F5F5F5"),
      R(0.38, 0, 0.4, 0.2, 1, "F5F5F5"),
      E(0.72, 0, 0.24, 0.22, 1, "F5F5F5"),
      deco(R(0.38, 0, 0.06, 0.2, 0, "E53935")),
      deco(R(0.48, 0, 0.06, 0.21, 0, "E53935")))

thing("guitar", "Guitar",
      E(-0.55, 0, 0.42, 0.47, WOOD, "D4823B"),
      E(-0.05, 0, 0.32, 0.35, WOOD, "D4823B"),
      hole(E(-0.25, 0, 0.12, 0.12, 0, "000000")),
      R(0.5, 0, 0.9, 0.12, 0.9, "6D4C2F"),
      R(0.9, 0, 0.16, 0.2, 0.9, "4E342E", corner=0.03),
      deco(R(-0.78, 0, 0.06, 0.3, 0, "4E342E")))

thing("swiss", "Swiss Cheese",
      R(0, 0, 1.9, 1.1, 1, "FBD25B", corner=0.05),
      hole(E(0.55, -0.15, 0.25, 0.22, 0, "000000")),
      hole(E(0.3, 0.3, 0.15, 0.13, 0, "000000")),
      hole(E(0.75, 0.32, 0.12, 0.12, 0, "000000")),
      hole(E(-0.5, -0.25, 0.1, 0.1, 0, "000000")),
      hole(E(0.05, -0.3, 0.12, 0.14, 0, "000000")))

thing("sausage", "Sausage",
      C(-0.9, 0.05, 0.9, 0.05, 0.2, 1, "B5523B"),
      deco(C(-0.7, -0.05, 0.7, -0.05, 0.04, 0, "D47A5E")),
      deco(E(-0.98, 0.05, 0.05, 0.04, 0, "8E3B2A")),
      deco(E(0.98, 0.05, 0.05, 0.04, 0, "8E3B2A")))

thing("pear", "Pear",
      E(-0.35, 0, 0.55, 0.55, 1, "A5D65B"),
      E(0.35, 0, 0.38, 0.33, 1, "A5D65B"),
      R(0.82, 0, 0.2, 0.05, 0.5, "6D4C2F"),
      P([(0.82, -0.02), (0.95, -0.22), (0.7, -0.12)], 0.2, "4CAF50"))

thing("key", "Key",
      E(-0.65, 0, 0.32, 0.32, STEEL, "FFC83D"),
      hole(E(-0.68, 0, 0.13, 0.13, 0, "000000")),
      R(0.15, 0, 1.4, 0.13, STEEL, "FFC83D", corner=0.05),
      R(0.62, 0.13, 0.08, 0.16, STEEL, "FFC83D"),
      R(0.78, 0.15, 0.08, 0.22, STEEL, "FFC83D"),
      R(0.9, 0.12, 0.06, 0.14, STEEL, "FFC83D"))

thing("racket", "Tennis Racket",
      C(-0.95, 0, -0.3, 0, 0.07, 1.2, "37474F"),
      E(0.38, 0, 0.58, 0.45, 1.4, "26C6DA"),
      E(0.38, 0, 0.5, 0.37, 0.12, "E0F7FA"),
      *[deco(R(0.38 + dx, 0, 0.01, 0.72 * math.sqrt(max(0, 1 - (dx / 0.5) ** 2)), 0, "80DEEA")) for dx in (-0.36, -0.24, -0.12, 0, 0.12, 0.24, 0.36)],
      *[deco(R(0.38, dy, 0.98 * math.sqrt(max(0, 1 - (dy / 0.37) ** 2)), 0.01, 0, "80DEEA")) for dy in (-0.24, -0.12, 0, 0.12, 0.24)])

thing("rocket", "Rocket",
      P([(-0.75, -0.42), (-0.5, -0.2), (-0.5, 0.2), (-0.75, 0.42), (-0.85, 0.42), (-0.6, 0), (-0.85, -0.42)], 1.2, "E53935"),
      C(-0.6, 0, 0.45, 0, 0.22, 0.6, "ECEFF1"),
      P([(0.45, -0.22), (0.95, 0), (0.45, 0.22)], 1.5, "E53935"),
      deco(E(0.15, 0, 0.09, 0.09, 0, "4FC3F7")),
      deco(P([(-0.82, -0.12), (-1.0, 0), (-0.82, 0.12)], 0, "FFB300")))

thing("dumbbell", "Dumbbell",
      R(0, 0, 1.6, 0.1, STEEL, "90A4AE"),
      R(-0.72, 0, 0.22, 0.9, STEEL, "37474F", corner=0.05),
      R(-0.5, 0, 0.12, 0.7, STEEL, "455A64", corner=0.04),
      R(0.72, 0, 0.16, 0.6, STEEL, "37474F", corner=0.05))

thing("axe", "Axe",
      R(-0.2, 0, 1.55, 0.12, WOOD, "B07A45", corner=0.05),
      P([(0.45, -0.1), (0.62, -0.12), (0.95, -0.55), (0.98, 0.5), (0.62, 0.12), (0.45, 0.1)], STEEL, "90A4AE"),
      deco(P([(0.88, -0.45), (0.95, -0.5), (0.97, 0.45), (0.9, 0.4)], 0, "CFD8DC")))

thing("bottle", "Juice Bottle",
      R(-0.25, 0, 1.3, 0.62, GLASS, "A5D6A7", corner=0.15),
      R(-0.25, 0, 1.2, 0.52, 0.02, "17202C", corner=0.12),
      R(-0.48, 0, 0.74, 0.52, 1, "FF9800", corner=0.1),
      R(0.6, 0, 0.42, 0.24, GLASS, "A5D6A7", corner=0.05),
      R(0.6, 0, 0.42, 0.14, 0.02, "17202C"),
      R(0.86, 0, 0.12, 0.28, 1, "E53935", corner=0.03))

thing("snowman", "Snowman",
      E(-0.55, 0, 0.42, 0.42, SNOW, "F5F5F5"),
      E(0.08, 0, 0.3, 0.3, SNOW, "F5F5F5"),
      E(0.5, 0, 0.2, 0.2, SNOW, "F5F5F5"),
      R(0.78, 0, 0.14, 0.38, 1, "263238"),
      R(0.9, 0, 0.18, 0.22, 1, "263238"),
      deco(P([(0.5, -0.04), (0.52, 0.04), (0.42, 0.26)], 0, "FF9800")),
      *[deco(E(x, 0, 0.035, 0.035, 0, "263238")) for x in (-0.3, -0.05, 0.12)])

thing("umbrella", "Umbrella",
      P(arc(0.1, 0, 0.62, 0.95, -90, 90, 30), 0.3, "7E57C2"),
      *[deco(P([(0.1, 0), (0.1 + 0.62 * math.cos(math.radians(a)), 0.95 * math.sin(math.radians(a))),
                (0.1 + 0.62 * math.cos(math.radians(a + 18)), 0.95 * math.sin(math.radians(a + 18)))], 0, "9575CD"))
        for a in (-90, -36, 18, 72)],
      R(-0.4, 0, 1.0, 0.07, STEEL, "455A64"),
      P(arc(-0.9, 0.2, 0.2, 0.2, -90, -270, 16) + arc(-0.9, 0.2, 0.13, 0.13, -270, -90, 16), STEEL, "455A64"))

thing("boot", "Boot",
      P([(-0.9, -0.6), (-0.2, -0.6), (-0.2, 0.1), (0.85, 0.15), (0.95, 0.4), (0.9, 0.55), (-0.9, 0.55)], 0.8, "8D6E63"),
      R(-0.65, 0.6, 0.5, 0.18, 2.2, "3E2723", corner=0.04),
      R(0.3, 0.6, 1.2, 0.08, 1.2, "3E2723"),
      deco(R(-0.55, -0.45, 0.7, 0.1, 0, "6D4C41")))

thing("wrench", "Wrench",
      E(-0.68, 0, 0.3, 0.3, STEEL, "B0BEC5"),
      hole(P([(-0.68 + 0.12 * math.cos(math.radians(a)), 0.12 * math.sin(math.radians(a))) for a in range(0, 360, 60)], 0, "000000")),
      R(0.05, 0, 1.2, 0.18, STEEL, "B0BEC5", corner=0.06),
      E(0.7, 0, 0.32, 0.42, STEEL, "B0BEC5"),
      hole(R(0.86, 0, 0.3, 0.18, 0, "000000")))

thing("golf", "Golf Club",
      C(-0.95, -0.05, 0.6, -0.05, 0.035, 1, "B0BEC5"),
      C(-0.95, -0.05, -0.55, -0.05, 0.06, 0.8, "212121"),
      P([(0.55, -0.12), (0.78, -0.15), (0.98, 0.25), (0.88, 0.42), (0.55, 0.3)], STEEL, "78909C"))

thing("trophy", "Trophy",
      R(-0.82, 0, 0.22, 0.8, 3, "6D4C41", corner=0.04),
      R(-0.25, 0, 0.95, 0.12, 2, "FFC107"),
      E(-0.2, 0, 0.09, 0.16, 2, "FFC107"),
      P(arc(0.85, 0, 0.66, 0.62, 90, 270, 24), 2, "FFC107"),
      hole(P(arc(0.9, 0, 0.56, 0.52, 90, 270, 24), 0, "000000")),
      deco(R(0.84, 0, 0.03, 1.22, 0, "FFE082")))

thing("sailboat", "Sailboat",
      P([(-0.95, 0.3), (-0.95, -0.3), (-0.6, -0.55), (-0.6, 0.55)], 2, "8D6E63"),
      R(0.15, 0, 1.5, 0.05, WOOD, "5D4037"),
      P([(-0.55, 0.02), (0.9, 0.02), (-0.55, 0.65)], 0.1, "FFFFFF"),
      P([(-0.55, -0.02), (0.7, -0.02), (-0.55, -0.5)], 0.1, "FFEB3B"))

thing("cactus", "Cactus",
      R(-0.15, 0, 1.6, 0.36, 0.9, "43A047", corner=0.18),
      R(-0.05, -0.32, 0.18, 0.4, 0.9, "43A047", corner=0.09),
      R(0.2, -0.55, 0.5, 0.18, 0.9, "43A047", corner=0.09),
      R(-0.35, 0.32, 0.18, 0.4, 0.9, "43A047", corner=0.09),
      R(-0.55, 0.55, 0.5, 0.18, 0.9, "43A047", corner=0.09),
      P([(-0.95, -0.3), (-0.95, 0.3), (-0.75, 0.25), (-0.75, -0.25)], 2.5, "D84315"))

thing("bulb", "Light Bulb",
      E(0.25, 0, 0.62, 0.62, 0.15, "FFF59D"),
      R(-0.45, 0, 0.3, 0.42, 0.15, "FFF59D"),
      R(-0.68, 0, 0.32, 0.42, 4, "9E9E9E", corner=0.04),
      R(-0.88, 0, 0.12, 0.22, 4, "616161", corner=0.04),
      deco(P([(-0.3, -0.1), (0.2, -0.15), (0.2, 0.15), (-0.3, 0.1)], 0, "FFB300")))

thing("egg", "Golden Egg",
      P(egg(0, 0, 0.95, 0.68), 1.2, "FFD54F"),
      E(-0.22, 0.05, 0.38, 0.36, 3, "FFB300"),
      deco(E(0.25, -0.3, 0.18, 0.08, 0, "FFF8E1", a=-20)))

# ---------------------------------------------------------------- levels
# tol: how close to 50% you must be (in %). rot: starting turn (degrees).
# wobble: it rocks back and forth this many degrees. move: it slides by itself
# (in object sizes) and you can't drag it. hide: "silhouette" (colors go) or
# "vanish" (the whole thing goes) after a few seconds.

LEVELS = [
    # Easy Cuts (free)
    dict(t="baguette", tol=5, tip="Drag the bread so the line cuts it in the middle. Then fold your phone!"),
    dict(t="cheese", tol=4, tip="Careful: the fat end has more cheese than the pointy end."),
    dict(t="carrot", tol=4, tip="The leaves are light. The orange part is heavy."),
    # Kitchen Classics
    dict(t="banana", tol=3, rot=35, tip="Banana bends. Half the banana is not half the box."),
    dict(t="lollipop", tol=3, tip="Candy is heavy. The stick weighs almost nothing."),
    dict(t="hammer", tol=3, tip="Steel is 8 times heavier than wood!"),
    dict(t="icecream", tol=3, tip="The scoop is heavier than the cone."),
    dict(t="fish", tol=3, rot=12, tip="The tail is thin and light."),
    dict(t="pizza", tol=3, tip="The crust is the heaviest part."),
    # Wobbly
    dict(t="spoon", tol=2.5, wobble=12, period=3.2, tip="It's wobbling! Fold when it's the right way."),
    dict(t="mushroom", tol=2.5, wobble=15, period=3.0, tip="The cap is big but light and fluffy."),
    dict(t="drumstick", tol=2.5, wobble=18, period=2.8, tip="Bone is heavier than meat."),
    dict(t="pin", tol=2.5, wobble=20, period=2.6, tip="Bowling pins are fat at the bottom."),
    dict(t="guitar", tol=2.5, wobble=22, period=2.6, tip="Mind the hole in the middle!"),
    dict(t="swiss", tol=2.5, wobble=25, period=2.4, tip="Holes weigh nothing. Look where they are."),
    # On the Move
    dict(t="sausage", tol=3, move=0.8, period=3.6, tip="It won't hold still! Fold at just the right moment."),
    dict(t="pear", tol=3, move=0.8, period=3.4, tip="Wait for the fat part to pass the line."),
    dict(t="key", tol=3, move=0.8, period=3.2, tip="The ring has a hole. The teeth are tiny."),
    dict(t="racket", tol=3, move=0.9, period=3.0, rot=-10, tip="Strings are light. The frame is not."),
    dict(t="rocket", tol=3, move=0.9, period=2.8, tip="The red parts are heavy metal."),
    dict(t="dumbbell", tol=3, move=1.0, period=2.6, tip="One side has more weights."),
    # Now You See It
    dict(t="axe", tol=2.5, hide="silhouette", tip="Look fast! The colors go away in 3 seconds."),
    dict(t="bottle", tol=2.5, hide="silhouette", tip="Remember where the juice is."),
    dict(t="snowman", tol=2.5, hide="silhouette", rot=8, tip="The hat is heavy. Snow is light."),
    dict(t="umbrella", tol=2.5, hide="vanish", tip="It disappears! Remember where it was."),
    dict(t="boot", tol=2.5, hide="vanish", rot=-6, tip="The heel is the heaviest part."),
    dict(t="wrench", tol=2.5, hide="vanish", tip="Two holes. Remember them."),
    # Master Chef
    dict(t="golf", tol=2, move=0.7, period=3.0, wobble=10, tip="Moving AND wobbling. Good luck!"),
    dict(t="trophy", tol=2, hide="silhouette", wobble=15, period=2.8, tip="The wood base is heavy."),
    dict(t="sailboat", tol=2, hide="silhouette", move=0.8, period=3.0, tip="Sails are paper light."),
    dict(t="cactus", tol=1.5, wobble=20, period=2.2, rot=15, tip="The pot is heavy clay."),
    dict(t="bulb", tol=1.5, hide="vanish", wobble=12, period=2.6, tip="Glass is thin. The metal base is heavy."),
    dict(t="egg", tol=1, hide="silhouette", move=0.7, period=2.6, wobble=12, tip="The final boss. The gold yolk is heavy!"),
]

CHAPTERS = [(1, "Easy Cuts"), (4, "Kitchen Classics"), (10, "Wobbly"), (16, "On the Move"),
            (22, "Now You See It"), (28, "Master Chef")]

# ---------------------------------------------------------------- weighing (same math as Thing.swift)


def rot(x, y, a):
    c, s = math.cos(math.radians(a)), math.sin(math.radians(a))
    return x * c - y * s, x * s + y * c


def contains(p, x, y):
    k = p["kind"]
    if k == "ellipse":
        lx, ly = rot(x - p["cx"], y - p["cy"], -p["a"])
        return (lx / p["rx"]) ** 2 + (ly / p["ry"]) ** 2 <= 1
    if k == "rect":
        lx, ly = rot(x - p["cx"], y - p["cy"], -p["a"])
        lx, ly, hw, hh = abs(lx), abs(ly), p["w"] / 2, p["h"] / 2
        if lx > hw or ly > hh:
            return False
        r = min(p["corner"], hw, hh)
        qx, qy = lx - (hw - r), ly - (hh - r)
        return not (qx > 0 and qy > 0 and qx * qx + qy * qy > r * r)
    if k == "capsule":
        ax, ay, bx, by = p["x1"], p["y1"], p["x2"], p["y2"]
        dx, dy = bx - ax, by - ay
        t = max(0, min(1, ((x - ax) * dx + (y - ay) * dy) / max(dx * dx + dy * dy, 1e-9)))
        return (x - ax - t * dx) ** 2 + (y - ay - t * dy) ** 2 <= p["r"] ** 2
    inside = False
    pts = p["pts"]
    j = len(pts) - 1
    for i in range(len(pts)):
        xi, yi = pts[i]
        xj, yj = pts[j]
        if (yi > y) != (yj > y) and x < (xj - xi) * (y - yi) / (yj - yi) + xi:
            inside = not inside
        j = i
    return inside


GRID, SPAN = 150, 1.15


def samples(t):
    out = []
    step = 2 * SPAN / GRID
    weighed = [p for p in t["parts"] if p["role"] != "deco"]
    for i in range(GRID):
        y = -SPAN + (i + 0.5) * step
        for j in range(GRID):
            x = -SPAN + (j + 0.5) * step
            m = 0
            for p in reversed(weighed):
                if contains(p, x, y):
                    m = p["d"] if p["role"] == "solid" else 0
                    break
            if m > 0:
                out.append((x, y, m))
    return out


def perfect_offset(pts, angle):
    proj = sorted((rot(x, y, angle)[0], m) for x, y, m in pts)
    half = sum(m for _, m in proj) / 2
    run = 0
    for px, m in proj:
        run += m
        if run >= half:
            return -px
    return 0


# ---------------------------------------------------------------- Swift output


def num(v):
    s = f"{v:.3f}".rstrip("0").rstrip(".")
    return "0" if s in ("-0", "") else s


def swift_part(p):
    role = "" if p["role"] == "solid" else f", role: .{p['role']}"
    d = "" if p["role"] != "solid" else f", weight: {num(p['d'])}"
    c = f"color: 0x{p['c']}"
    k = p["kind"]
    if k == "ellipse":
        a = f", turn: {num(p['a'])}" if p["a"] else ""
        return f".ellipse({num(p['cx'])}, {num(p['cy'])}, {num(p['rx'])}, {num(p['ry'])}{a}{d}, {c}{role})"
    if k == "rect":
        corner = f", corner: {num(p['corner'])}" if p["corner"] else ""
        a = f", turn: {num(p['a'])}" if p["a"] else ""
        return f".rect({num(p['cx'])}, {num(p['cy'])}, {num(p['w'])}, {num(p['h'])}{corner}{a}{d}, {c}{role})"
    if k == "capsule":
        return f".capsule({num(p['x1'])}, {num(p['y1'])}, {num(p['x2'])}, {num(p['y2'])}, {num(p['r'])}{d}, {c}{role})"
    pts = ", ".join(f"({num(x)}, {num(y)})" for x, y in p["pts"])
    return f".poly([{pts}]{d}, {c}{role})"


def write_swift():
    lines = [
        "// Made by scripts/levels.py - change the levels there, then run it again.",
        "",
        "import Foundation",
        "",
        "extension Thing {",
    ]
    for key, t in THINGS.items():
        lines.append(f'    static let {key} = Thing(name: "{t["name"]}", parts: [')
        for p in t["parts"]:
            lines.append(f"        {swift_part(p)},")
        lines.append("    ])")
    lines.append("}")
    lines.append("")
    lines.append("extension Level {")
    lines.append("    static let all: [Level] = [")
    for n, lv in enumerate(LEVELS, 1):
        args = [f"number: {n}", f"thing: .{lv['t']}", f"tolerance: {num(lv['tol'])}"]
        for key, label in (("rot", "turn"), ("wobble", "wobble"), ("move", "move"), ("period", "period")):
            if key in lv:
                args.append(f"{label}: {num(lv[key])}")
        if "hide" in lv:
            args.append(f"hide: .{lv['hide']}")
        tip = lv["tip"].replace('"', '\\"')
        args.append(f'tip: "{tip}"')
        lines.append(f"        Level({', '.join(args)}),")
    lines.append("    ]")
    lines.append("")
    lines.append("    static let chapters: [(first: Int, name: String)] = [")
    for first, name in CHAPTERS:
        lines.append(f'        ({first}, "{name}"),')
    lines.append("    ]")
    lines.append("}")
    with open(OUT, "w") as f:
        f.write("\n".join(lines) + "\n")
    print("wrote", OUT)


def preview(path):
    from PIL import Image, ImageDraw

    cell, cols = 260, 6
    rows = math.ceil(len(LEVELS) / cols)
    img = Image.new("RGB", (cols * cell, rows * cell), (16, 12, 34))
    d = ImageDraw.Draw(img)
    for n, lv in enumerate(LEVELS):
        t = THINGS[lv["t"]]
        ox, oy = (n % cols) * cell + cell / 2, (n // cols) * cell + cell / 2 + 10
        s = cell * 0.42
        a = lv.get("rot", 0)
        pts = samples(t)
        for x, y, m in pts[::1]:
            wx, wy = rot(x, y, a)
            shade = min(255, int(60 + m * 40))
            d.point((ox + wx * s, oy + wy * s), fill=(shade, shade, 90))
        best = perfect_offset(pts, a)
        xs = [rot(x, y, a)[0] for x, y, _ in pts]
        box_mid = (min(xs) + max(xs)) / 2
        cut = ox - best * s
        d.line([(cut, oy - s), (cut, oy + s)], fill=(255, 60, 60), width=2)
        d.line([(ox + box_mid * s, oy - s), (ox + box_mid * s, oy + s)], fill=(80, 160, 255), width=1)
        d.text((ox - cell / 2 + 6, oy - cell / 2 - 6), f"{n + 1} {t['name']}  off {abs(best + box_mid):.2f}", fill=(255, 255, 255))
    img.save(path)
    print("saved", path)


if __name__ == "__main__":
    write_swift()
    if len(sys.argv) > 1:
        preview(sys.argv[1])
