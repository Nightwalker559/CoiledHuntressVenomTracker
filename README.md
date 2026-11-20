# The Coiled Huntress Venom Tracker

A small movable display for two values Blizzard only shows in a tooltip:

- **Venom / Toxin** stacks on your equipped Coiled Huntress fishing rod (item 244790)
- **Coiled Filament** currency (id 3546), gained by converting Venom at Seasage Polo

For World of Warcraft Retail. The frame picks up the ElvUI skin automatically.

**Author:** Nightwalker559 · **License:** MIT with AI restriction

---

## Usage

The display only appears while the Coiled Huntress is equipped in your profession tool slot. It updates after every successful catch and whenever your Coiled Filament amount changes. The close (X) button hides it until you use `/venom toggle`; re-equipping the rod does not bring it back.

| Command | Effect |
| --- | --- |
| `/venom` | Manual refresh |
| `/venom toggle` | Show or hide the frame |
| `/venom unlock`, `/venom lock` | Unlock the frame to drag it, or lock it in place |
| `/venom reset` | Reset the frame to the screen center |
| `/venom dump` | Print raw tooltip lines (for locale debugging) |

## Locales

The Venom label is detected from the client locale: Venom (enUS/enGB), Toxin (deDE), venin (frFR), veneno (esES/esMX), veleno (itIT), Peçonha (ptBR), яд (ruRU), 맹독 (koKR), 毒液 (zhCN/zhTW).

If the tracker shows "n/a" while the rod is equipped, the locale keyword was not found in the tooltip (it does not mean the value is 0), and a one-time warning is printed to chat. Run `/venom dump` to see the real tooltip line and adjust the keyword at the top of the Lua file.

---

See the [changelog](https://github.com/Nightwalker559/CoiledHuntressVenomTracker/blob/main/CHANGELOG.md) for the version history.

## Feedback

Found a bug or have an idea? [Open an issue on GitHub](https://github.com/Nightwalker559/CoiledHuntressVenomTracker/issues).

## License

MIT with AI restriction (no use for AI or machine learning), see [LICENSE.md](https://github.com/Nightwalker559/CoiledHuntressVenomTracker/blob/main/LICENSE.md).
