# Changelog

## 1.0.6
- Fixed a false "couldn't find 'Toxin'" chat warning right after login: the tooltip is filled in lazily, so the warning now only appears if the keyword line stays missing for 5 seconds (and the timer resets when the rod is unequipped)

## 1.0.5
- Synced with the Venom Tracker module of Night's Farmtracker: the stale-value rescan is now event-driven (`TOOLTIP_DATA_UPDATE`, matched by the rod's `dataInstanceID`) instead of fixed 0.5s / 1.5s retry timers; no `C_Timer.After` with a delay is left
- Scans are queued via `RunNextFrame` (event bursts collapse into one scan); casts without the rod equipped are ignored early
- No tooltip scanning in combat, re-scan on `PLAYER_REGEN_ENABLED`
- `UNIT_SPELLCAST_SUCCEEDED` is registered for the player unit only
- Locale mismatch warning is now really shown once per session (it was stored permanently in the SavedVariables)
- Cleanup: removed dead `IsAddOnLoaded` fallback and single-entry keyword table, deduplicated refresh logic, unified chat prefix, plain-text keyword match

## 1.0.4
- Added optional ElvUI skin for the frame and close button (only applied if ElvUI is loaded)
- Toc bump
## 1.0.3
- Fixed stale Venom/Toxin value shown right after a catch (tooltip data lagged behind the actual stat); rescan is now retried shortly after trigger events

## 1.0.2
- Added and confirmed locale keywords for all WoW client languages via Wowhead / in-game: frFR (venin), esES/esMX (veneno), itIT (veleno), ptBR (Peçonha), ruRU (яд), koKR (맹독), zhCN/zhTW (毒液)
- Robust check: locale keyword mismatch now shows "n/a" instead of a misleading "0"
- One-time chat warning if the venom keyword can't be found in the tooltip, pointing to `/venom dump`

## 1.0.1
- Close button (X) on frame to hide it manually
- `/venom toggle` command to show/hide, hidden state persists
- Frame now widens automatically for long values (e.g. filament > 9999)
- Cleanup: removed unused code and a redundant event that caused unnecessary scans

## 1.0.0
- Movable frame tracking Venom/Toxin stacks on The Coiled Huntress (item 244790)
- Second line tracking Coiled Filament currency (id 3546)
- Auto-detects equip state — frame hides when the rod isn't equipped
- Locale-aware label and keyword detection (deDE: Toxin, enUS/enGB: Venom)
- Updates on cast success, equipment change, and currency change
- `/venom lock|unlock|reset|dump` commands
