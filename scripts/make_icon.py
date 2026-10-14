"""Draws the Exactly Half app icon (1024x1024, no transparency).

A round fruit cut exactly in half: a cyan half and a pink half pulled
slightly apart, with a glowing white blade line where the iPhone Duo folds.
Run: python3 scripts/make_icon.py
"""
import sys

from PIL import Image, ImageChops, ImageDraw, ImageFilter

S = 4096  # draw big, then shrink for smooth edges
OUT = sys.argv[1] if len(sys.argv) > 1 else "AppAssets/Assets.xcassets/AppIcon.appiconset/AppIcon.png"
CYAN = (51, 230, 255)
PINK = (255, 77, 191)
WHITE = (255, 255, 255)


def lerp(a, b, t):
    return tuple(int(a[i] + (b[i] - a[i]) * t) for i in range(3))


img = Image.new("RGB", (S, S))
d = ImageDraw.Draw(img)
for y in range(S):
    d.line([(0, y), (S, y)], fill=lerp((10, 8, 31), (26, 5, 46), y / (S - 1)))

glow = Image.new("RGB", (S, S))
g = ImageDraw.Draw(glow)
shapes = Image.new("RGB", (S, S))
sh = ImageDraw.Draw(shapes)


def both(draw_fn):
    draw_fn(g)
    draw_fn(sh)


r, gap, cy = 1300, 150, S / 2 + 60
# Left half (cyan) and right half (pink), each a half circle, a little apart and tipped.
both(lambda dr: dr.pieslice([S / 2 - gap - r, cy - r - 40, S / 2 - gap + r, cy + r - 40], 90, 270, fill=CYAN))
both(lambda dr: dr.pieslice([S / 2 + gap - r, cy - r + 40, S / 2 + gap + r, cy + r + 40], 270, 90, fill=PINK))
# Lighter flesh inside each half.
inner = 1050
sh.pieslice([S / 2 - gap - inner, cy - inner - 40, S / 2 - gap + inner, cy + inner - 40], 90, 270, fill=lerp(CYAN, WHITE, 0.55))
sh.pieslice([S / 2 + gap - inner, cy - inner + 40, S / 2 + gap + inner, cy + inner + 40], 270, 90, fill=lerp(PINK, WHITE, 0.55))
# Seeds.
for dx, dy in [(-420, -300), (-560, 120), (-330, 460)]:
    sh.ellipse([S / 2 - gap + dx - 70, cy + dy - 40 - 110, S / 2 - gap + dx + 70, cy + dy - 40 + 110], fill=(20, 60, 80))
    sh.ellipse([S / 2 + gap - dx - 70, cy + dy + 40 - 110, S / 2 + gap - dx + 70, cy + dy + 40 + 110], fill=(90, 20, 60))
# The blade.
both(lambda dr: dr.rounded_rectangle([S / 2 - 34, 380, S / 2 + 34, S - 380], radius=34, fill=WHITE))

glow = glow.filter(ImageFilter.GaussianBlur(110))
img = ImageChops.add(img, glow.point(lambda v: int(v * 0.85)))
mask = shapes.convert("L").point(lambda v: 255 if v > 8 else 0)
img.paste(shapes, (0, 0), mask)

img.resize((1024, 1024), Image.LANCZOS).save(OUT)
print("saved", OUT)
