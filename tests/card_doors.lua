-- Exercise the feature with April's real settings, menu shim, and bind system.
local P = "april_card_doors_enabled"
local passed = 0
local function test(name, fn)
    fn()
    passed = passed + 1
    print("PASS " .. name)
end

local function fixture()
    local c = { now = 0, calls = {}, notices = {}, down = {}, result = 2, frame = 0 }
    local mods = { ["ui.gs_widgets"] = {}, ["core.gpu_chams"] = {}, ["core.cache"] = { waypoints = {} } }
    mods["core.notify"] = { toast = function(msg, kind, duration, skip_dedupe)
        c.notices[#c.notices + 1] = { msg = msg, kind = kind }
        assert(duration == 2500 and skip_dedupe == true)
    end }
    local function gc(name)
        return function(key, value)
            assert(key == "InteractDistance" and (value == 0 or value == 5))
            c.calls[#c.calls + 1] = { name = name, value = value }
            if c.throw then error("mock GC failure") end
            return c.result
        end
    end
    local env = setmetatable({
        utility = { get_tick_count = function() return c.now end },
        input = { IsKeyDown = function(key) return c.down[key] == true end },
        setgc = gc("setgc"), applygc = gc("applygc"),
        thread = { Create = function() error("feature must not create a thread") end },
        OnFrame = function() error("feature must not replace the frame hook") end,
    }, { __index = _G })
    env.April = { custom_ui = true, require = function(name) return assert(mods[name], name) end }
    local function load_module(path)
        local mod = assert(loadfile((SOURCE_ROOT or ".") .. "/src/" .. path:gsub("%.", "/") .. ".lua", "t", env))()
        mods[path] = mod
        return mod
    end
    local original_frame = env.OnFrame
    c.state = load_module("ui.gs_state")
    env.menu = load_module("ui.menu_shim").api()
    local settings = load_module("core.settings")
    c.bind = load_module("core.feature_bind")
    c.menu_util = load_module("core.menu_util")
    c.feature = load_module("features.utility.card_doors")
    c.feature.register_menu()
    assert(env.OnFrame == original_frame)
    c.step = function(ms)
        c.now = c.now + (ms or 16)
        c.frame = c.frame + 1
        settings.begin_frame(c.frame)
        c.bind.tick()
        c.feature.update(0.016)
    end
    c.env, c.load = env, load_module
    return c
end

test("card doors starts disabled with an unassigned Toggle keypicker", function()
    local c = fixture()
    assert(c.state.get(P) == false and c.state.get_key(P) == 0)
    assert(c.bind.is_registered(P) and c.state.get(P .. "_mode") == 2)
    c.down[0x4C] = true
    c.step()
    assert(#c.calls == 0 and #c.notices == 0, "L must not be hardcoded")
    -- Existing keybinds retain their original Always default.
    c.menu_util.register_keybind("April", "Misc", "existing", "Existing", false)
    assert(c.state.get("existing_mode") == 0)
    c.load("ui.catalog_items")
    local found
    for _, group in ipairs(c.load("ui.catalog_misc").build()) do
        for _, item in ipairs(group.items) do
            if item.id == P then found = item end
        end
    end
    assert(found and found.type == "keybind" and found.label == "Open card doors")
end)

test("card doors uses one full scan per toggle and cached 3-second maintenance", function()
    local c = fixture()
    c.state.set(P, true)
    c.step(0)
    assert(#c.calls == 1 and c.calls[1].name == "setgc" and c.calls[1].value == 5)
    assert(c.notices[1].kind == "success")
    for _ = 1, 299 do c.step(10) end
    assert(#c.calls == 1)
    c.step(10)
    assert(#c.calls == 2 and c.calls[2].name == "applygc")
    assert(#c.notices == 1, "maintenance must not spam notifications")
    c.state.set(P, false)
    c.step()
    assert(#c.calls == 3 and c.calls[3].name == "setgc" and c.calls[3].value == 0)
    assert(c.notices[2].msg == "Interaction distance reset to 0.")
    c.step(60000)
    assert(#c.calls == 3, "disabled feature must stop applying")
end)

test("key capture does not activate card doors; assigned key toggles once per press", function()
    local c = fixture()
    c.state.set_key(P, 0x4B)
    c.down[0x4B] = true
    c.step()
    assert(#c.calls == 0)
    c.down[0x4B] = false
    c.step()
    c.down[0x4B] = true
    c.step()
    assert(#c.calls == 1 and c.calls[1].value == 5)
    c.step()
    assert(#c.calls == 1)
    c.down[0x4B] = false
    c.step()
    c.down[0x4B] = true
    c.step()
    assert(#c.calls == 2 and c.calls[2].value == 0)
end)

test("Hold mode follows the selected key and resets on release", function()
    local c = fixture()
    c.state.set_key(P, 0x4B)
    c.state.set(P .. "_mode", 1)
    c.state.set(P, true)
    c.step()
    assert(#c.calls == 0)
    c.down[0x4B] = true
    c.step()
    assert(c.calls[1].value == 5)
    c.down[0x4B] = false
    c.step()
    assert(c.calls[2].value == 0)
end)

test("missing GC APIs and empty results do not report success", function()
    local c = fixture()
    c.env.setgc = false
    c.state.set(P, true)
    c.step()
    c.step(3000)
    assert(#c.calls == 0 and #c.notices == 1 and c.notices[1].kind == "danger")
    c.state.set(P, false)
    c.step()
    assert(#c.calls == 0)

    c = fixture()
    c.result = 0
    c.state.set(P, true)
    c.step()
    c.step(3000)
    assert(#c.notices == 1 and c.notices[1].kind == "warning")
    c.result = 2
    c.step(3000)
    assert(#c.notices == 2 and c.notices[2].kind == "success")
    c.throw = true
    c.state.set(P, false)
    c.step()
    assert(c.notices[3].kind == "danger" and c.notices[3].msg:find("may remain", 1, true))
end)

test("card-door bind preferences survive registration and are included in configs", function()
    local c = fixture()
    c.state.set_key(P, 0x4B)
    c.state.set(P, true)
    c.state.set(P .. "_mode", 1)
    c.feature.register_menu()
    assert(c.state.get_key(P) == 0x4B and c.state.get(P .. "_mode") == 1)
    local config = c.load("core.config_store")
    local snapshot
    for i = 1, 100 do
        local name, value = debug.getupvalue(config.save_config, i)
        if not name then break end
        if name == "build_snapshot_lines" then snapshot = value end
    end
    local text = table.concat(assert(snapshot)("test"), "\n")
    assert(text:find(P .. "=true", 1, true))
    assert(text:find(P .. "_mode=1", 1, true))
    assert(text:find("@key:" .. P .. "=75", 1, true))
end)

print(string.format("Card doors: %d tests passed", passed))
