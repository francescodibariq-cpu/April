You replace **the entire `npc_esp.lua` file** with the rewrite. That's the only file that changes.

But my previous message got cut off mid-file. Here's the **complete, final `npc_esp.lua`** — paste this over your existing one in full:

```lua
local settings = April.require("core.settings")
local cache = April.require("core.cache")
local draw_util = April.require("core.draw_util")
local esp_util = April.require("core.esp_util")
local env = April.require("core.env")
local menu_util = April.require("core.menu_util")
local esp_scan = April.require("game.esp_scan")
local npcs = April.require("game.npcs")

local M = {}
local P = "april_npc_enabled"
local HP_TTL_MS = 250

cache.npcs = cache.npcs or {}

local function tick_ms()
    return utility and utility.get_tick_count and utility.get_tick_count() or 0
end

-- Map toggle ids -> kind used by the draw table, so entries built either by an
-- external scanner (entry.toggle_id) or by this module (entry.kind) both work.
local TOGGLE_TO_KIND = {
    april_npc_soldier     = "soldier",
    april_npc_bruno       = "bruno",
    april_npc_boris       = "boris",
    april_npc_brutus      = "brutus",
    april_npc_attack_heli = "heli",
    april_npc_btr         = "btr",
    april_npc_diver_dave  = "diver_dave",
    april_npc_pilot_pete  = "pilot_pete",
}

local function entry_kind(entry)
    if not entry then return nil end
    if entry.kind then return entry.kind end
    if entry.toggle_id then return TOGGLE_TO_KIND[entry.toggle_id] end
    return nil
end

local function migrate_legacy_types()
    if M._legacy_migrated then return end
    M._legacy_migrated = true
    if not menu or not menu.set then return end

    if settings.bool("april_npc_soldiers", false) then
        menu.set("april_npc_soldier", true)
        if menu.set_color then
            menu.set_color("april_npc_soldier", settings.color("april_npc_soldiers", { 1, 0.3, 0.3, 1 }))
        end
    end
    if settings.bool("april_npc_bosses", false) then
        local color = settings.color("april_npc_bosses", { 1, 0.5, 0.1, 1 })
        for _, id in ipairs({ "april_npc_bruno", "april_npc_boris", "april_npc_brutus" }) do
            menu.set(id, true)
            if menu.set_color then menu.set_color(id, color) end
        end
    end
    if settings.bool("april_npc_heli", false) then
        menu.set("april_npc_attack_heli", true)
        if menu.set_color then
            menu.set_color("april_npc_attack_heli", settings.color("april_npc_heli", { 0.85, 0.2, 0.25, 1 }))
        end
    end
end

function M.register_menu()
    local G = menu_util.G
    local T, _ = menu_util.group(G.WORLD)
    local root = menu_util.parent(P)

    menu_util.section(T, G.WORLD, "NPCs")
    menu_util.register_keybind(T, G.WORLD, P, "NPC ESP", false)
    menu.add_checkbox(T, G.WORLD, "april_npc_soldier", "Soldier", false, menu_util.parent(P, { colorpicker = { 1, 0.3, 0.3, 1 } }))
    menu.add_checkbox(T, G.WORLD, "april_npc_bruno", "Bruno", false, menu_util.parent(P, { colorpicker = { 1, 0.65, 0.2, 1 } }))
    menu.add_checkbox(T, G.WORLD, "april_npc_boris", "Boris", false, menu_util.parent(P, { colorpicker = { 0.78, 0.42, 1, 1 } }))
    menu.add_checkbox(T, G.WORLD, "april_npc_brutus", "Brutus", false, menu_util.parent(P, { colorpicker = { 1, 0.3, 0.48, 1 } }))
    menu.add_checkbox(T, G.WORLD, "april_npc_attack_heli", "Attack Heli", false, menu_util.parent(P, { colorpicker = { 0.85, 0.2, 0.25, 1 } }))
    menu.add_checkbox(T, G.WORLD, "april_npc_btr", "BTR", false, menu_util.parent(P, { colorpicker = { 0.95, 0.25, 0.15, 1 } }))
    menu.add_checkbox(T, G.WORLD, "april_npc_diver_dave", "Diver Dave", false, menu_util.parent(P, { colorpicker = { 0.2, 0.75, 1, 1 } }))
    menu.add_checkbox(T, G.WORLD, "april_npc_pilot_pete", "Pilot Pete", false, menu_util.parent(P, { colorpicker = { 0.35, 1, 0.65, 1 } }))
    menu.add_combo(T, G.WORLD, "april_npc_box_mode", "NPC Box", { "None", "2D", "Corner" }, 1, root)
    menu.add_checkbox(T, G.WORLD, "april_npc_health", "NPC Health Bar", true, root)
    menu.add_checkbox(T, G.WORLD, "april_npc_show_name", "NPC Show Name", true,
        menu_util.parent(P, { colorpicker = { 1, 0.3, 0.3, 1 } }))
    menu.add_checkbox(T, G.WORLD, "april_npc_show_distance", "NPC Show Distance", true,
        menu_util.parent(P, { colorpicker = { 0.82, 0.84, 0.88, 0.92 } }))

    menu_util.gap(T, G.WORLD)
    menu.add_slider_int(T, G.WORLD, "april_npc_range", "NPC Range", 50, 2000, 500, root)

    menu_util.bind_children(P, {
        "april_npc_soldier", "april_npc_bruno", "april_npc_boris", "april_npc_brutus",
        "april_npc_attack_heli", "april_npc_btr", "april_npc_diver_dave", "april_npc_pilot_pete",
        "april_npc_box_mode", "april_npc_health",
        "april_npc_show_name", "april_npc_show_distance",
        "april_npc_range",
    })
end

-- ---------------------------------------------------------------------------
-- Self-contained NPC scanning -> cache.npcs
--
-- Walks the workspace NPC roots one child at a time via the shared
-- incremental_scan budget. Uses npcs.classify if game.npcs provides it, else
-- falls back to a name-keyword matcher so entries still populate.
-- ---------------------------------------------------------------------------

local NPC_ROOT_NAMES = {
    NPCs = true,
    Npcs = true,
    npcs = true,
    NPCS = true,
    Enemies = true,
    Enemy = true,
    Mobs = true,
    Animals = true,
    Wildlife = true,
}

local NPC_KEYWORDS = {
    { "brutus",   "brutus",      "Brutus" },
    { "bruno",    "bruno",       "Bruno" },
    { "boris",    "boris",       "Boris" },
    { "attackheli", "heli",      "Attack Heli" },
    { "heli",     "heli",        "Attack Heli" },
    { "btr",      "btr",         "BTR" },
    { "diverdave","diver_dave",  "Diver Dave" },
    { "diver",    "diver_dave",  "Diver Dave" },
    { "pilotpete","pilot_pete",  "Pilot Pete" },
    { "pilot",    "pilot_pete",  "Pilot Pete" },
    { "soldier",  "soldier",     "Soldier"
