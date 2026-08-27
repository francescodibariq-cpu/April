# tools/

Local generators and one-off extractors. Not shipped in `april.lua`.

| Script | Use |
|--------|-----|
| `extract_catalog_strings.mjs` / `extract_ui_strings.mjs` | Pull UI labels for i18n |
| `transliterate_i18n.mjs` / `gen_fallback_ru.mjs` | Russian UI fallbacks |
| `build_anime_dialogue_module.mjs` / `expand_anime_dialogue.mjs` | Announcer lines → `src/game/anime_announcer_data.lua` |
| `sync-mod-ids.mjs` / `compare-mod-ids.mjs` | Staff roster vs `src/game/mod_ids.lua` |
| `extract_gc_keys.mjs` / `build_gc_static_catalog.mjs` | Weapon GC key research |
| `rbxlx_dump.mjs` | Place dump helper (prefer `npm run dump` in `scripts/`) |

Dump / GC research output belongs in gitignored `dump/` and `RE/`.
