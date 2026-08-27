local I = April.require("ui.catalog_items")

local cb, sl, combo, multi, btn, sep, color, input, hk =
    I.cb, I.sl, I.combo, I.multi, I.btn, I.sep, I.color, I.input, I.hk

local M = {}

function M.build()
    local modes = { "Static", "Rainbow", "Pulse", "Wave", "Flow" }
    local elem_modes = { "Default", "Static", "Rainbow", "Pulse", "Wave", "Flow" }
    local COL = "april_ui_custom_colors"
    local ANM = "april_ui_custom_anim"
    local ELS = "april_ui_per_element"
    local OVL = "april_ui_menu_overlay"
    local SNOW = "april_ui_snow"

    local appearance = {
        title = "Appearance",
        items = {
            I.label("Look", true),
            hk("april_ui_menu_key", "Menu Toggle Key"),
            combo("april_ui_theme_preset", "Theme Preset", {
                "Violet Glass", "Midnight Blue", "Graphite", "Emerald Glass",
                "Crimson Ember", "Arctic Frost", "Amber Noir", "Sakura Night",
                "Ocean Abyss", "Copper Dust", "Neon Lime", "Royal Indigo",
            }, 0),
            sep(),
            sl("april_ui_window_opacity", "Window Opacity %", 45, 100, 86),
            sl("april_ui_panel_opacity", "Panel Opacity %", 35, 100, 72),
            sl("april_ui_border_strength", "Border Strength %", 10, 100, 58),
            combo("april_ui_corner_style", "Corners", { "Sharp", "Soft", "Rounded" }, 2),
            sl("april_ui_scale", "UI Scale %", 80, 125, 100),
            combo("april_ui_density", "Density", { "Compact", "Balanced", "Comfortable" }, 1),
            cb("april_ui_show_cursor_dot", "Cursor Dot", true),
            sep(),
            I.label("Backdrop", true),
            cb("april_ui_menu_overlay", "Menu Overlay", true),
            sl("april_ui_overlay_strength", "Overlay Strength", 5, 100, 70, false, OVL),
            sep(),
            I.label("Snow", true),
            cb("april_ui_snow", "Enable Snow", false),
            sl("april_ui_snow_amount", "Amount", 10, 140, 50, false, SNOW),
            sl("april_ui_snow_speed", "Speed", 1, 100, 40, false, SNOW),
            sl("april_ui_snow_size", "Size", 1, 8, 3, false, SNOW),
            sl("april_ui_snow_opacity", "Opacity", 10, 100, 55, false, SNOW),
        },
    }

    local motion = {
        title = "Motion",
        items = {
            I.label("Basics", true),
            cb("april_ui_startup_intro", "Startup Animation", true),
            combo("april_ui_motion_profile", "Motion Profile", {
                "Subtle", "Balanced", "Expressive",
            }, 1),
            cb("april_ui_reduce_motion", "Reduce Motion", false),
            sep(),
            I.label("Advanced", true),
            cb("april_ui_custom_anim", "Advanced Animation", false),
            combo("april_ui_accent_anim", "Accent Style", modes, 1, ANM),
            sl("april_ui_anim_speed", "Accent Speed", 1, 100, 40, false, ANM),
            cb("april_ui_menu_fade", "Ambient Fade Pulse", false, nil, ANM),
            multi("april_ui_anim_targets", "Animate", {
                "Title Bar", "Section Tops", "Sliders", "Scrollbars", "Navbar", "Switches", "Hover", "Overlay Panels",
            }, { true, true, true, true, true, true, true, true }, ANM),
            cb("april_ui_per_element", "Per-Element Styles", false, nil, ANM),
            sep(ANM),
            { type = "combo", id = "april_ui_style_title", label = "Title Bar", options = elem_modes, default = 0, gate = ANM, gate2 = ELS },
            { type = "combo", id = "april_ui_style_section", label = "Section Tops", options = elem_modes, default = 0, gate = ANM, gate2 = ELS },
            { type = "combo", id = "april_ui_style_slider", label = "Sliders", options = elem_modes, default = 0, gate = ANM, gate2 = ELS },
            { type = "combo", id = "april_ui_style_scroll", label = "Scrollbars", options = elem_modes, default = 0, gate = ANM, gate2 = ELS },
            { type = "combo", id = "april_ui_style_sidebar", label = "Navbar", options = elem_modes, default = 0, gate = ANM, gate2 = ELS },
            { type = "combo", id = "april_ui_style_checkbox", label = "Switches", options = elem_modes, default = 0, gate = ANM, gate2 = ELS },
            { type = "combo", id = "april_ui_style_overlay", label = "Overlay Panels", options = elem_modes, default = 0, gate = ANM, gate2 = ELS },
        },
    }

    local accent = {
        title = "Accent Colors",
        items = {
            I.label("Accent", true),
            cb("april_ui_custom_colors", "Custom Colors", false),
            color("april_ui_accent", "Main Accent", { 0.78, 0.20, 0.92, 1 }, COL),
            sep(COL),
            I.label("Overrides", true, COL),
            multi("april_ui_color_overrides", "Override For", {
                "Title Bar", "Section Tops", "Sliders", "Scrollbars", "Navbar", "Switches", "Overlay Panels",
            }, {}, COL),
            color("april_ui_col_title", "Title Bar", { 0.78, 0.20, 0.92, 1 }, COL, 1),
            color("april_ui_col_section", "Section Tops", { 0.78, 0.20, 0.92, 1 }, COL, 2),
            color("april_ui_col_slider", "Sliders", { 0.78, 0.20, 0.92, 1 }, COL, 3),
            color("april_ui_col_scroll", "Scrollbars", { 0.78, 0.20, 0.92, 1 }, COL, 4),
            color("april_ui_col_sidebar", "Navbar", { 0.78, 0.20, 0.92, 1 }, COL, 5),
            color("april_ui_col_checkbox", "Switches", { 0.78, 0.20, 0.92, 1 }, COL, 6),
            color("april_ui_col_overlay", "Overlay Panels", { 0.78, 0.20, 0.92, 1 }, COL, 7),
        },
    }

    local anime_baddie = {
        title = "Anime Baddie",
        master = "april_anime_baddie_enabled",
        items = {
            cb("april_anime_baddie_enabled", "Anime Baddie", false),
            I.label("Also toggled from the top dock.", true),
            combo("april_anime_baddie_character", "Character", { "April", "VectorChan" }, 0,
                "april_anime_baddie_enabled"),
            combo("april_anime_baddie_personality", "Personality", {
                "Mixed", "Roasty", "Supportive",
            }, 0, "april_anime_baddie_enabled"),
            multi("april_anime_baddie_events", "React To", {
                "Death / Respawn", "Downed / Revived", "Low Health", "Safe Zone",
                "Combat / Bleed", "Survival Needs", "Nearby Threats", "World Events",
            }, { true, true, true, true, true, true, true, true }, "april_anime_baddie_enabled"),
            sep("april_anime_baddie_enabled"),
            sl("april_anime_baddie_scale", "Scale", 60, 150, 100, false,
                "april_anime_baddie_enabled"),
            sl("april_anime_baddie_opacity", "Opacity", 30, 100, 100, false,
                "april_anime_baddie_enabled"),
            sl("april_anime_baddie_duration", "Bubble Duration", 2, 10, 5, false,
                "april_anime_baddie_enabled"),
            sl("april_anime_baddie_cooldown", "Chatter Cooldown", 2, 30, 8, false,
                "april_anime_baddie_enabled"),
            cb("april_anime_baddie_stay", "Stay Visible", true, nil,
                "april_anime_baddie_enabled"),
            sep("april_anime_baddie_enabled"),
            btn("april_anime_baddie_preview", "Preview Line", "april_anime_baddie_enabled"),
            btn("april_anime_baddie_reset", "Reset Position", "april_anime_baddie_enabled"),
        },
    }

    local cfg_labels = { "(no configs)" }
    pcall(function()
        local store = April.require("core.config_store")
        store.migrate_legacy()
        local labels = store.list_config_labels()
        if labels and #labels > 0 then
            cfg_labels = labels
        end
    end)

    local config_group = {
        title = "Config",
        items = {
            -- Latin-only: Vector's draw font has no Cyrillic glyphs (shows as ???).
            cb("april_ui_russian", "Russkiy yazyk", false),
            sep(),
            I.label("Configs", true),
            input("april_cfg_profile_name", "Config Name", "Default"),
            combo("april_cfg_selected", "Saved Configs", cfg_labels, 0),
            btn("april_cfg_save", "Save Config"),
            btn("april_cfg_load", "Load Config"),
            btn("april_cfg_delete", "Delete Config"),
            btn("april_cfg_refresh", "Refresh List"),
            sep(),
            I.label("Autoload", true),
            cb("april_cfg_autoload", "Autoload on Start", false),
            input("april_cfg_autoload_config", "Autoload Config Name", "", "april_cfg_autoload"),
            sep(),
            I.label("Extras", true),
            sl("april_esp_text_size", "ESP Text Size", 8, 24, 13),
            btn("april_reload_modules", "Reload Game Modules"),
        },
    }

    return { appearance, motion, accent, anime_baddie, config_group }
end

return M
