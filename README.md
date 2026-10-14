# Exactly Half

Cut things exactly in half, using your foldable iPhone Duo as the knife.

1. **Open** the phone. The line down the middle of the screen is the hinge.
2. **Drag** the object until you think the line splits it into two equal weights.
3. **Fold** the phone closed. That's the chop.
4. **Open** it again. The halves land on a balance scale and you see the split, like 49.6% | 50.4%.

Heavy parts count more than big parts: a hammer's steel head beats its long wooden handle.

## Levels

- **3 free levels** (Easy Cuts), then **30 more** with the Full Game:
  Kitchen Classics, Wobbly (it rocks while you aim), On the Move (it slides by itself, so you fold at the right moment),
  Now You See It (the colors or the whole object vanish after 3 seconds) and Master Chef.
- Up to 3 stars per level. Each level asks you to get within a set % of 50/50.
- **Daily Cut** (free): a new mystery object every day, with a streak.
- **Blade Pack**: Laser, Katana, Chainsaw and Plasma cut lines.
- No fold? Settings has a **CUT button** (on by default on iPad), and a switch that turns the cut line if it doesn't sit on your hinge.

## Where things are

- `ExactlyHalf.swiftpm/` - all the game code. Open it in Swift Playgrounds on iPad to play right away.
- `ExactlyHalf.swiftpm/Game/LevelData.swift` - made by `python3 scripts/levels.py`. Change objects and levels in the script, not in the Swift file.
  `python3 scripts/levels.py preview.png` also draws every object with its perfect cut line.
- `project.yml` - builds the App Store app from the same code (XcodeGen).
- `AppAssets/` - app icon. Redraw it with `python3 scripts/make_icon.py`.

## In-app purchases

Make these in App Store Connect with the same IDs:

| Product ID | Type | What |
| --- | --- | --- |
| `com.ariberkowitz.exactlyhalf.fullgame` | Non-consumable | Levels 4-33 |
| `com.ariberkowitz.exactlyhalf.blades` | Non-consumable | Blade Pack |
| `com.ariberkowitz.exactlyhalf.all` | Non-consumable | All Access (both) |
| `com.ariberkowitz.exactlyhalf.tip.small` | Consumable | Small tip |
| `com.ariberkowitz.exactlyhalf.tip.big` | Consumable | Big tip |

## TestFlight

Needs the repo secrets `ASC_KEY_ID`, `ASC_ISSUER_ID` and `ASC_KEY_P8` (App Store Connect API key, Admin),
and an app in App Store Connect with the bundle ID `com.ariberkowitz.exactlyhalf`.
Run the "Upload to TestFlight" action, or push a commit with `[testflight]` in the message.
