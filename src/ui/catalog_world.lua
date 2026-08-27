local I = April.require("ui.catalog_items")
local maps = April.require("game.esp_maps")

local cb, kb, sl, combo, multi =
    I.cb, I.kb, I.sl, I.combo, I.multi

local M = {}

function M.build()
    local resources = {
        title = "Resources",
        master = "april_world_enabled",
        items = {
            kb("april_world_enabled", "Resource ESP", false),
        },
    }
    I.append(resources.items, I.from_toggles(maps.WORLD_TOGGLES))
    I.append(resources.items, {
        cb("april_world_boxes", "Resource 3D Boxes", false),
        cb("april_world_show_name", "Resource Show Name", true),
        cb("april_world_show_distance", "Resource Show Distance", true),
        sl("april_world_range", "Resource Range", 50, 2000, 500),
    })
    I.append(resources.items, I.mesh_chams_block("april_world", maps.WORLD_TOGGLES, "april_world_enabled"))

    local loot = {
        title = "Loot",
        master = "april_loot_enabled",
        items = {
            kb("april_loot_enabled", "Loot ESP", false),
        },
    }
    I.append(loot.items, I.from_toggles(maps.LOOT_TOGGLES))
    I.append(loot.items, {
        cb("april_loot_boxes", "Loot 3D Boxes", false),
        cb("april_loot_show_name", "Loot Show Name", true),
        cb("april_loot_show_distance", "Loot Show Distance", true),
        sl("april_loot_range", "Loot Range", 50, 2000, 300),
    })
    I.append(loot.items, I.mesh_chams_block("april_loot", maps.LOOT_TOGGLES, "april_loot_enabled"))

    local bases = {
        title = "Bases",
        master = "april_base_enabled",
        items = {
            kb("april_base_enabled", "Base ESP", false),
        },
    }
    I.append(bases.items, I.from_toggles(maps.BASE_TOGGLES))
    I.append(bases.items, {
        cb("april_base_boxes", "Base 3D Boxes", false),
        cb("april_base_show_name", "Base Show Name", true),
        cb("april_base_show_distance", "Base Show Distance", false),
        sl("april_base_range", "Base Range", 50, 500, 150),
    })
    I.append(bases.items, I.mesh_chams_block("april_base", maps.BASE_TOGGLES, "april_base_enabled"))

    local base_xray = {
        title = "Base Xray",
        master = "april_base_xray_enabled",
        items = {
            kb("april_base_xray_enabled", "Base Xray", false),
            sl("april_base_xray_range", "Xray Range", 40, 500, 180),
        },
    }

    local npcs = {
        title = "NPCs",
        master = "april_npc_enabled",
        items = {
            kb("april_npc_enabled", "NPC ESP", false, nil, { hide_color = true }),
            multi("april_ui_npc_types", "NPC Types", {
                "Soldier", "Bruno", "Boris", "Brutus", "Attack Heli", "BTR", "Diver Dave", "Pilot Pete",
            }, { false, false, false, false, false, false, false, false }, nil, {
                sync_ids = {
                    "april_npc_soldier", "april_npc_bruno", "april_npc_boris", "april_npc_brutus",
                    "april_npc_attack_heli", "april_npc_btr", "april_npc_diver_dave", "april_npc_pilot_pete",
                },
            }),
            combo("april_npc_box_mode", "NPC Box", { "None", "2D", "Corner" }, 1),
            multi("april_ui_npc_elements", "Displayed Elements", {
                "Health Bar", "Name", "Distance",
            }, { true, true, true }, nil, {
                sync_ids = {
                    "april_npc_health", "april_npc_show_name", "april_npc_show_distance",
                },
            }),
            sl("april_npc_range", "NPC Range", 50, 2000, 500),
        },
    }

    local npc_colors = {
        title = "NPC Colors",
        master = "april_npc_enabled",
        items = {
            I.color("april_npc_soldier", "Soldier", { 1, 0.3, 0.3, 1 }),
            I.color("april_npc_bruno", "Bruno", { 1, 0.65, 0.2, 1 }),
            I.color("april_npc_boris", "Boris", { 0.78, 0.42, 1, 1 }),
            I.color("april_npc_brutus", "Brutus", { 1, 0.3, 0.48, 1 }),
            I.color("april_npc_attack_heli", "Attack Heli", { 0.85, 0.2, 0.25, 1 }),
            I.color("april_npc_btr", "BTR", { 0.95, 0.25, 0.15, 1 }),
            I.color("april_npc_diver_dave", "Diver Dave", { 0.2, 0.75, 1, 1 }),
            I.color("april_npc_pilot_pete", "Pilot Pete", { 0.35, 1, 0.65, 1 }),
            I.color("april_npc_show_name", "Name", { 1, 0.3, 0.3, 1 }),
            I.color("april_npc_show_distance", "Distance", { 0.82, 0.84, 0.88, 0.92 }),
        },
    }

    local raids = {
        title = "Raids",
        master = "april_raid_enabled",
        items = {
            kb("april_raid_enabled", "Raid ESP", false, nil, { color = { 1, 0.5, 0, 1 } }),
            cb("april_raid_notifications", "Raid Notifications", true),
            sl("april_raid_range", "Raid ESP Range", 50, 5000, 1000),
        },
    }

    return { resources, loot, npcs, npc_colors, raids, bases, base_xray }
end

return M
