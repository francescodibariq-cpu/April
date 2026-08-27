local I = April.require("ui.catalog_items")

local cb, kb, sl, combo, sep, color =
    I.cb, I.kb, I.sl, I.combo, I.sep, I.color

local M = {}

function M.build()
    return {
        {
            title = "Gun Mods",
            master = "april_gunmods_enabled",
            items = {
                kb("april_gunmods_enabled", "Enable Gun Mods", false),
                sep(),
                cb("april_gm_recoil", "No Recoil", false),
                sl("april_gm_recoil_pct", "Recoil Reduction %", 0, 100, 100, false, "april_gm_recoil"),
                sep(),
                cb("april_gm_spread", "No Spread", false),
                sl("april_gm_spread_pct", "Spread Reduction %", 0, 100, 100, false, "april_gm_spread"),
                sep(),
                cb("april_gm_sway", "No Sway", false),
                sep(),
                cb("april_gm_fire_rate", "Fire Rate", false),
                sl("april_gm_fire_rate_mult", "Fire Rate Multiplier", 1, 3, 1.5, true, "april_gm_fire_rate"),
                sep(),
                cb("april_gm_speed", "Bullet Speed", false),
                sl("april_gm_speed_mult", "Speed Mult", 1, 100, 100, false, "april_gm_speed"),
                sep(),
                cb("april_gm_range", "Gun Range", false),
                sl("april_gm_range_mult", "Range Mult", 1, 20, 10, false, "april_gm_range"),
                sep(),
                cb("april_gm_double_tap", "Double Tap", false),
            },
        },
        {
            title = "Bullet Tracers",
            items = {
                kb("april_tracers_enabled", "Enable Tracers", false),
                sep(),
                color("april_tracers_color", "Tracer Color", { 1.0, 0.55, 0.18, 1.0 }, "april_tracers_enabled"),
                color("april_tracers_color2", "Tracer End Color", { 1.0, 0.2, 0.35, 1.0 }, "april_tracers_enabled"),
                combo("april_tracers_style", "Tracer Style", {
                    "Beam", "Glow", "Gradient", "Dashed", "Ribbon",
                }, 1, "april_tracers_enabled"),
                combo("april_tracers_anim", "Tracer Animation", {
                    "Fade", "Sweep", "Shrink", "Pulse", "Travel", "Bloom",
                }, 1, "april_tracers_enabled"),
                sl("april_tracers_anim_speed", "Anim Speed", 0.25, 3, 1, true, "april_tracers_enabled"),
                sep(),
                sl("april_tracers_lifetime", "Lifetime (ms)", 100, 1500, 550, false, "april_tracers_enabled"),
                sl("april_tracers_thickness", "Tracer Thickness", 0.5, 8, 2.2, true, "april_tracers_enabled"),
                sl("april_tracers_transparency", "Tracer Fade", 0, 0.9, 0.05, true, "april_tracers_enabled"),
                sl("april_tracers_segments", "Tracer Segments", 4, 48, 18, false, "april_tracers_enabled"),
                sl("april_tracers_glow", "Glow Strength", 0.2, 3, 1, true, "april_tracers_enabled"),
                sl("april_tracers_damage", "Min Damage", 1, 50, 10, false, "april_tracers_enabled"),
                sep(),
                cb("april_tracers_outline", "Tracer Outline", true, nil, "april_tracers_enabled"),
                cb("april_tracers_impact", "Impact Flash", true, nil, "april_tracers_enabled"),
                cb("april_tracers_rainbow", "Tracer Rainbow", false, nil, "april_tracers_enabled"),
            },
        },
    }
end

return M
