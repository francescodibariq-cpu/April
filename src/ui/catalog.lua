--[[
  Layout catalog for the custom Gamesense UI.
  Values / callbacks come from feature register_menu() via ui.menu_shim.
  Nested options use `gate` so they only appear under their parent toggle.

  Tab layouts live in ui.catalog_* modules. Edit those files when adding
  controls; this module only lists tabs and dispatches groups_for().
]]

local M = {}

M.TABS = {
    { id = "aim", icon = "aim", title = "Combat", label = "Aim", description = "Targeting, aim behavior, and bullet control" },
    { id = "visuals", icon = "visuals", title = "Visuals", label = "Visuals", description = "Player information, crosshair, gear, and audio" },
    { id = "world", icon = "world", title = "World", label = "World", description = "Resources, loot, NPCs, raids, and bases" },
    { id = "guns", icon = "guns", title = "Weapons", label = "Guns", description = "Weapon tuning and bullet tracer effects" },
    { id = "misc", icon = "misc", title = "Movement & Utility", label = "Misc", description = "Movement, automation, protection, and events" },
    { id = "radar", icon = "radar", title = "Radar", label = "Radar", description = "Tactical map layers and world waypoints" },
    { id = "config", icon = "config", title = "Settings", label = "Config", description = "Appearance, motion, profiles, and extras" },
}

local BUILDERS = {
    aim = "ui.catalog_aim",
    visuals = "ui.catalog_visuals",
    world = "ui.catalog_world",
    guns = "ui.catalog_guns",
    misc = "ui.catalog_misc",
    radar = "ui.catalog_radar",
    config = "ui.catalog_config",
}

local group_cache = {}
local EMPTY_GROUPS = {}

function M.invalidate(tab_id)
    if tab_id then
        group_cache[tab_id] = nil
    else
        for key in pairs(group_cache) do group_cache[key] = nil end
    end
end

function M.groups_for(tab_id)
    local cached = group_cache[tab_id]
    if cached then return cached end
    local path = BUILDERS[tab_id]
    if not path then return EMPTY_GROUPS end
    local groups = April.require(path).build()
    group_cache[tab_id] = groups
    return groups
end

return M
