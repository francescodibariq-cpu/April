local I = April.require("ui.catalog_items")

local cb, kb, sl, combo, multi, sep, color =
    I.cb, I.kb, I.sl, I.combo, I.multi, I.sep, I.color

local M = {}

function M.build()
    local left = {
        title = "Player ESP",
        master = "april_player_enabled",
        items = {
            kb("april_player_enabled", "Player ESP", false, nil, { hide_color = true }),
            combo("april_player_box_mode", "Player Box", { "None", "2D", "Corner" }, 1),
            multi("april_ui_player_elements", "Displayed Elements", {
                "Health Bar", "Skeleton", "Name", "Clan Tag", "Held Item", "Distance",
            }, { true, false, true, true, false, true }, nil, {
                sync_ids = {
                    "april_player_health", "april_player_skeleton", "april_player_show_name",
                    "april_player_clan_tag", "april_player_show_held", "april_player_show_distance",
                },
            }),
            multi("april_player_esp_filters", "ESP Filters", {
                "Team Check", "Skip Safezone", "Skip Downed",
            }, { true, false, false }),
            multi("april_player_esp_flags", "ESP Flags", {
                "Downed", "Safezone", "Staff", "Reviving", "Movement", "VIP", "Cheater", "Animation",
            }, { true, true, true, true, false, true, true, false }),
            sl("april_player_range", "Player Range", 50, 2000, 500),
        },
    }

    local gear = {
        title = "Target Gear",
        master = "april_target_overlay",
        items = {
            kb("april_target_overlay", "Target Gear Overlay", false),
            sl("april_target_overlay_fov", "Gear FOV", 5, 500, 100, false, "april_target_overlay"),
            sl("april_target_overlay_max_dist", "Max Distance", 50, 2000, 500, false, "april_target_overlay"),
            sl("april_target_overlay_gear_size", "Gear Icon Size", 32, 64, 48, false, "april_target_overlay"),
            sl("april_target_overlay_top", "Top Offset", 48, 160, 88, false, "april_target_overlay"),
        },
    }

    local target_vis = {
        title = "Crosshair",
        items = {
            cb("april_crosshair_enabled", "Custom Crosshair", false),
            combo("april_crosshair_type", "Style", {
                "Cross", "Circle", "Dot", "T-Shape", "Diamond", "Plus", "Brackets", "X",
            }, 0, "april_crosshair_enabled"),
            cb("april_crosshair_follow", "Follow Target", false, nil, "april_crosshair_enabled"),
            combo("april_crosshair_source", "Target From", { "Auto", "Silent Aim", "Aimbot" }, 0, "april_crosshair_follow"),
            sl("april_crosshair_follow_smooth", "Follow Smoothness", 4, 40, 18, false, "april_crosshair_follow"),
            multi("april_ui_crosshair_motion", "Motion", { "Spin", "Pulse Size" }, { false, false }, "april_crosshair_enabled", {
                sync_ids = { "april_crosshair_spin", "april_crosshair_pulse" },
            }),
            sl("april_crosshair_spin_speed", "Spin Speed", 1, 100, 35, false, "april_crosshair_spin"),
            sl("april_crosshair_pulse_speed", "Pulse Speed", 1, 100, 40, false, "april_crosshair_pulse"),
            multi("april_ui_crosshair_options", "Options", {
                "Center Dot", "Outline", "Rainbow",
            }, { false, true, false }, "april_crosshair_enabled", {
                sync_ids = {
                    "april_crosshair_dot", "april_crosshair_outline", "april_crosshair_rainbow",
                },
            }),
            color("april_crosshair_color", "Crosshair Color", { 0, 1, 0, 1 }, "april_crosshair_enabled"),
            color("april_crosshair_dot", "Center Dot Color", { 1, 1, 1, 1 }, "april_crosshair_dot"),
            sl("april_crosshair_rainbow_speed", "Rainbow Speed", 1, 100, 10, false, "april_crosshair_rainbow"),
            sl("april_crosshair_size", "Size", 1, 50, 10, false, "april_crosshair_enabled"),
            sl("april_crosshair_gap", "Gap", 0, 20, 5, false, "april_crosshair_enabled"),
            sl("april_crosshair_thickness", "Thickness", 1, 10, 2, false, "april_crosshair_enabled"),
        },
    }

    local colors = {
        title = "Player Colors",
        master = "april_player_enabled",
        items = {
            color("april_player_box_color", "Box", { 1, 0.35, 0.35, 1 }),
            color("april_player_skeleton", "Skeleton", { 1, 1, 1, 0.92 }),
            color("april_player_show_name", "Name", { 1, 0.35, 0.35, 1 }),
            color("april_player_clan_tag", "Clan Tag", { 0.84, 0.31, 0.80, 1 }),
            color("april_player_show_held", "Held Item", { 0.95, 0.9, 0.55, 0.95 }),
            color("april_player_show_distance", "Distance", { 0.82, 0.84, 0.88, 0.92 }),
            sep(),
            color("april_player_flag_downed", "Downed", { 1, 0.35, 0.35, 1 }),
            color("april_player_flag_safezone", "Safezone", { 0.35, 0.85, 1, 1 }),
            color("april_player_flag_staff", "Staff", { 1, 0.33, 0.33, 1 }),
            color("april_player_flag_reviving", "Reviving", { 0.45, 1, 0.55, 1 }),
            color("april_player_flag_movement", "Movement", { 0.75, 0.85, 1, 1 }),
            color("april_player_flag_vip", "VIP", { 1, 0.82, 0.2, 1 }),
            color("april_player_flag_cheater", "Cheater", { 1, 0.05, 0.05, 1 }),
            color("april_player_flag_animation", "Animation", { 0.95, 0.78, 1.0, 1 }),
        },
    }

    local sound_esp = {
        title = "Audio Radar",
        master = "april_sound_esp",
        items = {
            cb("april_sound_esp", "Sound ESP", false),
            I.label("original by @n0v313w", true, "april_sound_esp"),
            I.label("Uses Player ESP filters + range.", true, "april_sound_esp"),
            sep("april_sound_esp"),
            multi("april_sound_esp_filters", "Radar Filters", {
                "Footsteps", "Combat", "Utility", "World", "Other",
            }, { true, true, true, true, true }, "april_sound_esp"),
            cb("april_sound_esp_detail", "Radar Detail", true, nil, "april_sound_esp"),
            cb("april_sound_esp_cat_color", "Category Colors", true, nil, "april_sound_esp"),
            sep("april_sound_esp"),
            sl("april_sound_esp_fade_in", "Sound Fade In", 0.05, 2, 0.25, true, "april_sound_esp"),
            sl("april_sound_esp_fade_out", "Sound Fade Out", 0.5, 15, 5, true, "april_sound_esp"),
            sl("april_sound_esp_size", "Sound Text Size", 8, 20, 10, false, "april_sound_esp"),
            sl("april_sound_esp_under", "Under Offset", 0, 6, 2.8, true, "april_sound_esp"),
            sl("april_sound_esp_screen_y", "Screen Offset", -20, 40, 2, false, "april_sound_esp"),
            sl("april_sound_esp_max_dist", "Sound Range", 50, 2000, 450, false, "april_sound_esp"),
            sl("april_sound_esp_max_per", "Max Per Player", 1, 10, 4, false, "april_sound_esp"),
            cb("april_sound_esp_chip", "Sound Chip", false, nil, "april_sound_esp"),
            color("april_sound_esp_color", "Sound Color", { 0.78, 0.9, 1.0, 0.92 }, "april_sound_esp"),
        },
    }

    return { left, gear, target_vis, colors, sound_esp }
end

return M
