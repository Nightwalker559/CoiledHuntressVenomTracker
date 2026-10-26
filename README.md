# The Coiled Huntress Venom Tracker

Small movable display for two values that Blizzard doesn't expose anywhere
outside a tooltip:

- **Venom / Toxin** stacks on your equipped Coiled Huntress fishing rod (item 244790)
- **Coiled Filament** currency (id 3546), gained by converting Venom at Seasage Polo

## Installation

Copy the `CoiledHuntressVenomTracker` folder into:

```
World of Warcraft/_retail_/Interface/AddOns/
```

## Usage

The display only appears while the Coiled Huntress is equipped in your
profession tool slot. It updates automatically after every successful catch
and whenever your Coiled Filament amount changes.

## Commands

| Command | Effect |
|---|---|
| `/venom` | Manual refresh |
| `/venom toggle` | Show/hide the frame |
| `/venom unlock` | Unlock frame to drag it |
| `/venom lock` | Lock frame in place |
| `/venom reset` | Reset frame to screen center |
| `/venom dump` | Print raw tooltip lines (for locale debugging) |

The frame has a close (X) button in its top-right corner. Closing it this
way stays closed until you use `/venom toggle` — it won't reappear just
because you re-equip the rod.

## ElvUI

If ElvUI is installed, the frame and its close button automatically pick up
the ElvUI skin. No configuration needed.

## Locale support

Venom label auto-detects via client locale. All entries confirmed via
Wowhead item page or in-game:
- `deDE`: Toxin
- `enUS` / `enGB`: Venom
- `frFR`: venin
- `esES` / `esMX`: veneno
- `itIT`: veleno
- `ptBR`: Peçonha
- `ruRU`: яд
- `koKR`: 맹독
- `zhCN` / `zhTW`: 毒液

If the tracker ever shows "n/a" despite the rod being equipped, this means
the locale keyword wasn't found in the tooltip (not that the value is
actually 0). A one-time warning is printed to chat in this case. Run
`/venom dump` to see the real tooltip line and adjust the keyword for
your locale at the top of the Lua file.

## Author

Nightwalker559

## Feedback

Found a bug or have an idea? [Open an issue on GitHub](https://github.com/Nightwalker559/CoiledHuntressVenomTracker/issues).

## License

MIT with AI restriction (no use for AI or machine learning), see [LICENSE.md](https://github.com/Nightwalker559/CoiledHuntressVenomTracker/blob/main/LICENSE.md).
