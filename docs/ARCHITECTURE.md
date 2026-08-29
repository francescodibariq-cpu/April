# April Fallen — Architecture

How the runtime is assembled, started, and ticked. Edit `src/`; generated Lua is output.

## Artifacts

| File | Role |
|------|------|
| `src/` | Modular source. This is what you edit. |
| `scripts/bundle.mjs` | Packs `src/` into one Lua file. |
| `april.lua` | Full remote runtime (`utility.LoadUrl`). |
| `Script 1.lua` | Identical local test copy of `april.lua`. |
| `load.lua` | One-line LoadUrl pointing at GitHub `main`. |
| `src/ui/template/` | Standalone Gamesense UI kit (no game features). |

`april.lua` and `Script 1.lua` are generated. Do not hand-edit them.

## Boot sequence

1. Bundle header creates the global `April` table, `April.require`, and `April._mods`.
2. Each `src/*.lua` file is wrapped as `April._mods["path.with.dots"] = (function() ... end)()`.
3. Footer:
   - Installs `ui.menu_shim` so `menu.add_*` writes into `ui.gs_state` instead of Vector tabs.
   - Calls `menu.tabs.register_all()` which loads every feature in `FEATURE_ORDER` and runs `register_menu()`.
   - Calls `app.init()`: API check, offset boot, feature menus, incremental scans, config autoload.
   - Installs movement / xray hooks that need to live outside the frame callback.
   - Registers `on_frame` → `app.on_frame()`.

## Frame loop (`src/app.lua`)

Each `on_frame`:

1. `settings.begin_frame` — one menu/value read per id for the whole frame.
2. Feature keybind + aim-key tick.
3. Startup intro (if enabled) can draw and return early.
4. `menu.tabs.update(dt)`:
   - Entity cache refresh, NPC cache, player state, weapon tick
   - Incremental world/loot/base scans
   - Every feature `update(dt)` in `FEATURE_ORDER`
5. Overlay theme sync, feature `draw()`, notifications, custom menu.

Draw only happens here. Settings are read through `core.settings` (`enabled` / `num` / `get`), which goes to the shimmed `menu.get` → `ui.gs_state`.

## Two-layer menu

Features still call `menu.add_checkbox(...)` etc. in `register_menu()`. That no longer creates Vector UI. `ui/menu_shim.lua` stores defaults, colors, and keys in `ui.gs_state`.

Visible layout lives in the catalog:

| File | Tab |
|------|-----|
| `ui/catalog.lua` | Tab list + `groups_for` dispatcher |
| `ui/catalog_items.lua` | Shared `cb` / `sl` / `combo` helpers |
| `ui/catalog_aim.lua` | Aimbot / silent / bullet |
| `ui/catalog_visuals.lua` | Player ESP / crosshair / audio radar |
| `ui/catalog_world.lua` | Resources / loot / NPC / raids / bases |
| `ui/catalog_guns.lua` | Gun mods / tracers |
| `ui/catalog_misc.lua` | Movement / utility |
| `ui/catalog_radar.lua` | Tactical map / waypoints |
| `ui/catalog_config.lua` | Appearance / config save |

`ui/custom_menu.lua` draws the window (INSERT). `ui/hud_dock.lua` is the top-bar panel toggles (binds, staff, events, map, announcer).
`ui/search_palette.lua` indexes every tab, group, control, option, and setting id. Search navigation returns a catalog target to `custom_menu.lua`, which handles tab selection, group expansion, autoscroll, and the temporary highlight without mutating feature values.

Adding a control: default in the feature's `register_menu()`, layout row in the matching `catalog_*.lua`. Labels must stay unique within a tab+group.

## Feature contract

A feature module typically exports:

- `register_menu()` — define setting ids/defaults (via shim)
- `update(dt)` — logic, optional
- `draw()` — overlay drawing, optional
- `install()` — some movement/world hooks run once from the bundle footer

Libraries used by combat (targeting, silent resolve, bullet TP, whitelist) are bundled but not listed in `FEATURE_ORDER`; they are required by `aimbot.lua` / `camera_aimbot.lua`.

`features/visuals/crosshair.lua` is an alias of `target_visuals.lua`.

## Source map

```
src/core/       Vector glue, settings, cache, math, movement primitives
src/game/       Fallen-specific data (items, weapons, folders, NPC kinds)
src/features/   One folder per domain: combat, visuals, world, movement, radar, utility
src/ui/         Gamesense menu, catalog, HUD, intro
src/menu/       Feature registration + per-frame dispatch (`tabs.lua`)
src/app.lua     Init + on_frame
```

## Build

```bash
npm run build              # april.lua + Script 1.lua + load.lua
npm run build:ui           # april_ui.lua (real catalog, no features)
npm run build:ui-template  # "april UI.lua" demo kit from src/ui/template/
```

Bundle ORDER must not be regrouped by folder. Several core modules `April.require` game data at load time (`ui_theme` → `mod_ids`, `image_cache` → `asset_urls`). The bundler warns about `src/` Lua files missing from ORDER (`src/ui/template/` is excluded on purpose).
