# `src/` module map

Edit here. `April.require("folder.file")` loads `src/folder/file.lua`.

## Entry

| Module | Role |
|--------|------|
| `app` | Init + `on_frame` |
| `menu.tabs` | Feature list, `register_all`, scans, update/draw dispatch |

## `core/`

Runtime glue for Project Vector: env/API aliases, entity property helpers, per-frame settings cache, draw/math, silent ray, movement CFrame helpers, config store, GPU chams, incremental scanner.

## `game/`

Fallen Survival data: workspace folders, item/weapon catalogs, GC gun-mod keys, NPC kinds, inventory, team/player state, map tiles, staff/mod ids.

## `features/`

| Folder | What ticks |
|--------|------------|
| `combat/` | Aimbot, silent resolve, gun mods, FOV flags, farm helper |
| `visuals/` | Player ESP, sound ESP, tracers, target overlay, crosshair |
| `world/` | Resource / loot / base / NPC / raid ESP, base xray |
| `movement/` | Fly, spider, bhop, desync, anti-aim, fake duck, fling, anti-fling |
| `radar/` | Tactical map, waypoints |
| `utility/` | Autofarm, config, staff checker, events, keybind HUD, announcer, anti-AFK |

Combat helpers (`targeting`, `silent_resolve`, `bullet_tp_ray`, …) are libraries required by `aimbot`, not separate menu features.

## `ui/`

| File / folder | Role |
|---------------|------|
| `catalog.lua` | Tab list + dispatcher |
| `catalog_*.lua` | Per-tab layout |
| `catalog_items.lua` | Shared control constructors |
| `custom_menu.lua` | Window, INSERT toggle, scrolling |
| `gs_*.lua` | Theme, input, widgets, state, icons, anim |
| `hud_dock.lua` | Top-bar HUD panel toggles |
| `menu_shim.lua` | `menu.*` → `gs_state` |
| `template/` | Standalone UI kit (not in the game bundle) |
