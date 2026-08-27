local settings = April.require("core.settings")
local menu_util = April.require("core.menu_util")
local notify = April.require("core.notify")

local M = {}
local P = "april_card_doors_enabled"
local KEY = "InteractDistance"
local DISTANCE = 5
local REFRESH_MS = 3000
local was_enabled = false
local attempted = false
local next_refresh = 0
local notice_state = nil

local function now_ms()
    local fn = utility and (utility.get_tick_count or utility.GetTickCount)
    return type(fn) == "function" and fn() or 0
end

local function report(state, message, kind)
    if notice_state == state then return end
    notice_state = state
    -- State transitions should still notify when the bind is toggled quickly.
    notify.toast(message, kind, 2500, true)
end

local function patch(fn, value)
    local ok, count = pcall(fn, KEY, value)
    return ok and type(count) == "number" and count > 0
end

function M.register_menu()
    local G = menu_util.G.MISC
    menu_util.register_keybind(menu_util.group(G), G, P, "Open card doors", false,
        { key = 0, default_mode = 2 })
end

function M.update(_dt)
    local enabled = settings.enabled(P)
    local changed = enabled ~= was_enabled
    if changed then
        was_enabled = enabled
        notice_state = nil
    end

    if not enabled then
        if changed and attempted then
            -- This is the supplied script's reset, NOT restoration of every
            -- object's original value. Vector's key-based API is not scoped
            -- to card doors; BenchInfo also uses this key for other objects.
            if type(setgc) == "function" and patch(setgc, 0) then
                attempted = false
                report("reset", "Interaction distance reset to 0.", "warning")
            else
                report("reset_failed", "Interaction reset failed; the previous patch may remain.", "danger")
            end
        end
        return
    end

    local now = now_ms()
    if not changed and now < next_refresh then return end
    next_refresh = now + REFRESH_MS
    if type(setgc) ~= "function" or type(applygc) ~= "function" then
        report("unavailable", "Card-door interaction requires Vector's GC API.", "danger")
        return
    end

    attempted = true
    -- One thorough scan on activation; cached maintenance in April's existing
    -- update loop. No thread, additional OnFrame, or per-frame GC walk.
    local fn = changed and setgc or applygc
    if patch(fn, DISTANCE) then
        report("applied", "Card-door reach set to 5 studs.", "success")
    else
        report("pending", "No interaction patch confirmed; approach a card door and retry.", "warning")
    end
end

return M
