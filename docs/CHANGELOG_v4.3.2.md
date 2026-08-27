# April Fallen v4.3.2

## Features

- Added **Open card doors** under Misc → Utility. Bind a key to patch `InteractDistance` to 5 studs so card readers can be used from slightly farther away.
- The patch runs a full `setgc` scan when you turn it on, then refreshes cached entries with `applygc` every 3 seconds. Default bind mode is Toggle.
- Toasts report apply, reset, missing GC API, and unconfirmed patch states.
- **Warning:** Vector's key-based GC API changes every matching `InteractDistance` field, including other doors and benches. Turning the bind off sets matches to `0`, not their original distances. The server can still reject the interaction.

## Memory and Performance

- Image cache now prunes unused textures after 60 seconds of idle time, reference-counts handles that share a URL, and no longer pins every anime announcer sprite for the whole session.
- Anime announcer loads the selected character sprite on demand instead of preloading every expression at install.
- Manipulation-math caches expire abandoned searches, cap job and result counts, and prune from the frame loop.
- Map image no longer hits disk on every ready/draw poll, frees failed or replaced handles, and tracks resolved vs loaded asset ids so a changed map texture invalidates correctly.

## Gun Mods

- `applygc` now uses the documented payload-only signature.
- Failed GC warmups honor the existing apply interval instead of retrying every frame.

## UI and Source Layout

- Split the Gamesense catalog into per-tab modules (`src/ui/catalog_aim.lua`, `catalog_visuals.lua`, `catalog_world.lua`, `catalog_guns.lua`, `catalog_misc.lua`, `catalog_radar.lua`, `catalog_config.lua`).
- Shared control constructors live in `src/ui/catalog_items.lua`; `catalog.lua` only lists tabs and dispatches.
- Moved the standalone UI kit to `src/ui/template/` (not included in the game bundle).
- Keybinds can set a per-control default bind mode.

## Build and Tests

- Updated the release version to `4.3.2`.
- Bundler warns if a `src/` Lua file is missing from the load `ORDER` (`src/ui/template/` is excluded on purpose).
- Added offline Lua regression tests for card doors, image/map ownership, GC retry behavior, and cache pruning (`python tests/run_lua.py`).
- Rebuilt `april.lua`, `Script 1.lua`, and `load.lua`.
