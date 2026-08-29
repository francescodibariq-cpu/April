local I = April.require("ui.catalog_items")

local cb, kb, sl, combo, multi, sep =
    I.cb, I.kb, I.sl, I.combo, I.multi, I.sep

local M = {}

function M.build()
    return {
        {
            title = "Mobility",
            items = {
                kb("april_fly_enabled", "Fly", false),
                sl("april_fly_speed", "Fly Speed", 1, 20, 5, false, "april_fly_enabled"),
                cb("april_fly_noclip", "Fly Noclip", true, nil, "april_fly_enabled"),
                sep(),
                kb("april_spider_enabled", "Spider", false),
                sl("april_spider_speed", "Spider Speed", 18, 30, 18, false, "april_spider_enabled"),
                sep(),
                kb("april_bhop_enabled", "Bunny Hop", false),
            },
        },
        {
            title = "Combat Movement",
            items = {
                kb("april_desync_enabled", "Desync", false),
                cb("april_desync_visualizer", "Desync Visualize", false, { 0.2, 0.85, 1, 0.9 }, "april_desync_enabled"),
                sep(),
                kb("april_antiaim_enabled", "Anti-Aim", false),
                combo("april_antiaim_yaw_mode", "Yaw Mode", { "None", "Backwards", "Spin", "Jitter", "Random Jitter", "Sideways Left", "Sideways Right", "Manual" }, 1, "april_antiaim_enabled"),
                sl("april_antiaim_yaw_manual", "Manual Yaw", -180, 180, 90, false, "april_antiaim_enabled", {
                    gate_combo = "april_antiaim_yaw_mode",
                    gate_combo_value = 7,
                }),
                sl("april_antiaim_spin_speed", "Spin Speed", 30, 720, 180, false, "april_antiaim_enabled", {
                    gate_combo = "april_antiaim_yaw_mode",
                    gate_combo_value = 2,
                }),
                sl("april_antiaim_jitter_step", "Jitter Step", 15, 180, 90, false, "april_antiaim_enabled", {
                    gate_any_combo = {
                        { "april_antiaim_yaw_mode", { 3, 4 } },
                    },
                }),
                sl("april_antiaim_jitter_ms", "Jitter Interval (ms)", 40, 500, 120, false, "april_antiaim_enabled", {
                    gate_any_combo = {
                        { "april_antiaim_yaw_mode", { 3, 4 } },
                    },
                }),
                kb("april_fakeduck_enabled", "Fake Duck", false),
                sl("april_fakeduck_height", "Duck Height", 0.01, 1.5, 1.1, true, "april_fakeduck_enabled"),
                cb("april_fakeduck_spam", "Spam Height", false, nil, "april_fakeduck_enabled"),
                combo("april_fakeduck_spam_mode", "Spam Mode", { "Alternating", "Random" }, 0, "april_fakeduck_spam"),
                sl("april_fakeduck_spam_min", "Spam Min", 0.01, 1.5, 0.01, true, "april_fakeduck_spam"),
                sl("april_fakeduck_spam_max", "Spam Max", 0.01, 1.5, 1.5, true, "april_fakeduck_spam"),
                sl("april_fakeduck_spam_ms", "Spam Interval (ms)", 20, 400, 80, false, "april_fakeduck_spam"),
                sep(),
                kb("april_fling_enabled", "Fling", false),
                sl("april_fling_fov", "Fling FOV", 5, 600, 150, false, "april_fling_enabled"),
                sl("april_fling_duration", "Fling Duration", 2, 10, 2, false, "april_fling_enabled"),
            },
        },
        {
            title = "Automation",
            items = {
                kb("april_autofarm", "Autofarm", false),
                multi("april_autofarm_resources", "Farm Resources", {
                    "Trees", "Stone", "Metal", "Phosphate",
                }, { true, true, true, true }, "april_autofarm"),
                sl("april_autofarm_search_range", "Search Range", 50, 2000, 500, false, "april_autofarm"),
                cb("april_autofarm_debug_path", "Debug Target Path", false, nil, "april_autofarm"),
                sep(),
                kb("april_farm_helper", "Manual Farm Helper", false),
                sl("april_farm_radius", "Farm Range (studs)", 1, 10, 7, false, "april_farm_helper"),
            },
        },
        {
            title = "Protection & Access",
            items = {
                cb("april_anti_afk", "Anti AFK", false),
                kb("april_antifling_enabled", "Anti Fling", false),
            },
        },
        {
            title = "Event Status",
            master = "april_event_status_enabled",
            items = {
                kb("april_event_status_enabled", "Event Status", false),
                cb("april_event_status_active_only", "Only Show Active Events", false, nil, "april_event_status_enabled"),
                cb("april_event_status_notify", "Event Notifications", true, nil, "april_event_status_enabled"),
                cb("april_event_status_distance", "Show Event Distance", true, nil, "april_event_status_enabled"),
                cb("april_event_status_health", "Show Event Health", true, nil, "april_event_status_enabled"),
                combo("april_event_status_sort", "Event Sorting", {
                    "Game Order", "Active First", "Nearest First",
                }, 1, "april_event_status_enabled"),
                I.label("HUD panels are managed from the top dock."),
            },
        },
    }
end

return M
