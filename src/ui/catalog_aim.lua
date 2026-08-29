local I = April.require("ui.catalog_items")
local combat_menu = April.require("ui.combat_labels")

local cb, kb, sl, combo, multi, btn, sep, color, input, ak =
    I.cb, I.kb, I.sl, I.combo, I.multi, I.btn, I.sep, I.color, I.input, I.ak

local M = {}

function M.build()
    local regular = {
        title = "Aimbot",
        master = "april_aimbot",
        items = {
            kb("april_aimbot", "Enable Aimbot", false, nil, { hide_color = true }),
            ak("april_aim_key", "Aim Key"),
            sep(),
            I.label("Targeting", true),
            combo("april_aim_target_type", "Target Type", { "Crosshair", "Distance" }, 0),
            combo("april_aim_bone", "Hitbox", combat_menu.SILENT_BONES, 0),
            multi("april_aim_targets", "Aim At", combat_menu.AIM_AT_OPTIONS, combat_menu.AIM_AT_DEFAULTS),
            multi("april_aim_filters", "Filters", {
                "Health Check", "Visible Only", "Team Check",
                "Skip Safezone", "Whitelist", "Skip Downed",
            }, { true, false, true, true, false, true }),
            input("april_aim_whitelist_ids", "Whitelist IDs", ""),
            btn("april_aim_whitelist_clear", "Clear Whitelist"),
            sl("april_aim_max_dist", "Max Distance (m)", 50, 2000, 500),
            sep(),
            I.label("Behavior", true),
            cb("april_aim_sticky", "Sticky Aim", false),
            cb("april_aim_auto_pred", "Auto Prediction", true),
            sl("april_aim_smooth", "Smoothness", 1, 25, 10),
            combo("april_aim_smooth_type", "Smooth Type", {
                "Linear", "Ease Out", "Ease In-Out", "Exponential", "Adaptive",
            }, 0),
            cb("april_aim_humanize", "Humanize", false),
            sl("april_aim_humanize_str", "Humanize Strength", 1, 100, 35, false, "april_aim_humanize"),
            sl("april_aim_fov", "FOV Radius (px)", 5, 600, 120),
            sep(),
            I.label("Feedback", true),
            cb("april_aim_draw_fov", "FOV Circle", false, { 0.2, 1, 0.45, 1 }),
            combo("april_aim_fov_style", "FOV Style", { "Outline", "Filled Circle" }, 1, "april_aim_draw_fov"),
            cb("april_aim_target_line", "Target Line", false, { 0.2, 1, 0.45, 1 }),
        },
    }

    local fov_flags = {
        title = "FOV Flags",
        items = {
            cb("april_fov_flags_enabled", "Enable FOV Flags", false),
            sep(),
            cb("april_fov_flags_visible", "Visible Flag", true, nil, "april_fov_flags_enabled"),
            cb("april_fov_flags_distance", "Distance Flag", true, nil, "april_fov_flags_enabled"),
        },
    }

    local silent = {
        title = "Silent Aim",
        master = "april_silent_aim",
        items = {
            kb("april_silent_aim", "Enable Silent Aim", false, nil, { hide_color = true }),
            sep(),
            I.label("Targeting", true),
            combo("april_silent_target_type", "Target Type", { "Crosshair", "Distance" }, 0),
            combo("april_silent_bone", "Hitbox", combat_menu.SILENT_BONES, 0),
            multi("april_silent_targets", "Aim At", combat_menu.AIM_AT_OPTIONS, combat_menu.AIM_AT_DEFAULTS),
            multi("april_silent_filters", "Filters", {
                "Health Check", "Visible Only", "Team Check",
                "Skip Safezone", "Whitelist", "Skip Downed",
            }, { true, false, true, true, false, true }),
            input("april_silent_whitelist_ids", "Whitelist IDs", ""),
            btn("april_silent_whitelist_clear", "Clear Whitelist"),
            sl("april_silent_max_dist", "Max Distance (m)", 50, 2000, 500),
            sep(),
            I.label("Accuracy", true),
            cb("april_silent_sticky", "Sticky Aim", false),
            sl("april_silent_hit_chance", "Hit Chance %", 1, 100, 100),
            sl("april_silent_fov", "FOV Radius (px)", 5, 600, 150),
            sep(),
            I.label("Feedback", true),
            cb("april_silent_draw_fov", "FOV Circle", false, { 0.55, 0.2, 1, 1 }),
            combo("april_silent_fov_style", "FOV Style", { "Outline", "Filled Circle" }, 1, "april_silent_draw_fov"),
            cb("april_silent_target_line", "Snapline", false, { 1, 0.25, 0.25, 1 }),
        },
    }

    local bullet = {
        title = "Bullet",
        master = "april_bullet_enabled",
        items = {
            kb("april_bullet_enabled", "Enable Bullet", false),
            sep(),
            cb("april_silent_hitscan", "Hitscan", false),
            sep(),
            cb("april_silent_bullet_tp", "Bullet TP", false),
            sep("april_silent_bullet_tp"),
            cb("april_silent_bullet_manip", "Silent Bullet Manip", false),
            sl("april_silent_manip_dist", "Manip Distance", 0.1, 1, 1, true, "april_silent_bullet_manip"),
            cb("april_silent_manip_extend", "Extend", false, nil, "april_silent_bullet_manip"),
            sl("april_silent_manip_extend_dist", "Extend Distance", 1, 7, 7, true, "april_silent_manip_extend"),
            cb("april_bullet_body_peek", "Body Peek (desync)", false, nil, "april_silent_bullet_manip"),
            sep("april_bullet_enabled"),
            cb("april_thick_bullet", "Hitbox Override", false),
            sl("april_thick_bullet_mult", "Override Size", 1, 4, 2, true, "april_thick_bullet"),
            sep("april_bullet_enabled"),
            cb("april_silent_manip_status", "Status HUD", false, nil, "april_bullet_enabled"),
            cb("april_silent_manip_peek_vis", "Peek Visual", false, nil, "april_bullet_enabled"),
        },
    }

    return { regular, fov_flags, silent, bullet }
end

return M
