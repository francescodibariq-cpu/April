local I = April.require("ui.catalog_items")

local cb, kb, sl, multi, btn, color =
    I.cb, I.kb, I.sl, I.multi, I.btn, I.color

local M = {}

function M.build()
    return {
        {
            title = "Tactical Map",
            master = "april_map_enabled",
            items = {
                kb("april_map_enabled", "Tactical Map", false),
                multi("april_ui_radar_layers", "Visible Layers", {
                    "Players", "NPCs", "Loot", "Resources", "Base Parts", "Waypoints", "Raids", "Labels",
                }, { true, false, true, true, false, true, false, false }, nil, {
                    sync_ids = {
                        "april_map_show_players", "april_map_show_npcs", "april_map_show_loot",
                        "april_map_show_world", "april_map_show_base", "april_map_show_waypoints",
                        "april_map_show_raids", "april_map_labels",
                    },
                }),
                color("april_map_player_col", "Radar Players Color", { 1, 0.25, 0.25, 1 }),
                color("april_map_npc_col", "Radar NPCs Color", { 1, 0.55, 0.15, 1 }),
                color("april_map_loot_col", "Radar Loot Color", { 1, 0.85, 0.35, 1 }),
                color("april_map_world_col", "Radar Resources Color", { 0.35, 0.9, 0.35, 1 }),
                color("april_map_base_col", "Radar Base Color", { 0.55, 0.55, 1, 1 }),
                color("april_map_wp_col", "Radar Waypoints Color", { 0.3, 0.9, 1, 1 }),
                color("april_map_raid_col", "Radar Raids Color", { 1, 0.5, 0, 1 }),
                sl("april_map_zoom", "Radar Zoom Level", 0.05, 5, 1, true),
                sl("april_map_size", "Radar Size", 140, 420, 250),
                sl("april_map_opacity", "Radar Opacity", 15, 100, 100),
                sl("april_map_icon_scale", "Radar Blip Size", 2, 6, 3),
                btn("april_map_reset_position", "Reset Radar Position"),
            },
        },
        {
            title = "Waypoints",
            master = "april_waypoints_enabled",
            items = {
                kb("april_waypoints_enabled", "Waypoints", false),
                cb("april_wp_dist", "Waypoint Show Distance", false),
                cb("april_wp_beacon", "Beacon Pillar", false),
                sl("april_wp_beacon_h", "Beacon Height", 20, 200, 90, false, "april_wp_beacon"),
                cb("april_wp_draw", "Draw Markers", false, { 0.2, 1, 0.8, 1 }),
                sl("april_wp_slot", "Waypoint Active Slot", 1, 5, 1),
                btn("april_wp_set", "Set Active Waypoint"),
                btn("april_wp_clear", "Clear Active Waypoint"),
                btn("april_wp_clear_all", "Clear All Waypoints"),
            },
        },
    }
end

return M
