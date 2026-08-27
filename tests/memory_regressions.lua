-- Pure Lua regression tests. No Vector process, network, or game writes.
local passed, failed = 0, 0
local function test(name, fn)
    local ok, err = pcall(fn)
    if ok then passed = passed + 1 else failed = failed + 1 end
    print((ok and "PASS " or "FAIL ") .. name .. (ok and "" or (": " .. tostring(err))))
end

local function count(t)
    local n = 0
    for _ in pairs(t) do n = n + 1 end
    return n
end

local function upvalue(fn, name, seen)
    seen = seen or {}
    if seen[fn] then return nil end
    seen[fn] = true
    local children = {}
    for i = 1, 100 do
        local key, value = debug.getupvalue(fn, i)
        if not key then break end
        if key == name then return value end
        if type(value) == "function" then children[#children + 1] = value end
    end
    for _, child in ipairs(children) do
        local value = upvalue(child, name, seen)
        if value ~= nil then return value end
    end
end

local function load_module(path, modules, globals)
    local env = setmetatable(globals or {}, { __index = _G })
    env.April = { require = function(key)
        assert(modules[key], "missing test dependency: " .. key)
        return modules[key]
    end }
    return assert(loadfile((SOURCE_ROOT or ".") .. "/src/" .. path .. ".lua", "t", env))()
end

local quiet = { step = function() end, warn_once = function() end, step_done = function() end }
local function manip_fixture()
    local clock = { now = 0, visible = function() return false end }
    local m = load_module("core/manip_math", { ["core.math_util"] = { atan2 = math.atan } }, {
        utility = { get_tick_count = function() return clock.now end },
        raycast = { is_visible = function(...) return clock.visible(...) end },
    })
    return m, clock
end

test("moving targets cannot retain unbounded unfinished search jobs", function()
    local m, clock = manip_fixture()
    for i = 1, 10000 do
        clock.now = i * 16
        local result = m.evaluate_manipulation({ x = i, y = 0, z = 0 }, { x = i + 10, y = 0, z = 0 },
            { extend_extra = 7, ray_budget = 24 })
        assert(result.state == "scanning" and result.rays == 24, "ray budget changed")
    end
    local jobs = upvalue(m.evaluate_manipulation, "_jobs")
    print("  retained jobs after 10,000 moving requests: " .. count(jobs))
    assert(count(jobs) <= 128, "abandoned jobs grew with movement")
    clock.now = clock.now + 2500
    m.prune_caches()
    assert(count(jobs) == 0, "disabled feature left jobs retained")
end)

test("result caches are bounded even with a frozen clock", function()
    local m, clock = manip_fixture()
    for i = 1, 1000 do
        clock.visible = function(x) return x ~= i end
        assert(m.evaluate_manipulation({ x = i, y = 0, z = 0 }, { x = i + 10, y = 0, z = 0 }).state == "ready")
    end
    local positive = upvalue(m.evaluate_manipulation, "_peek_cache")
    assert(count(positive) <= 256, "positive cache has no hard bound")
    clock.visible = function() return false end
    for i = 1, 1000 do
        assert(m.evaluate_manipulation({ x = i, y = 0, z = 0 }, { x = i + 10, y = 0, z = 0 },
            { ray_budget = 10000 }).state == "blocked")
    end
    assert(count(upvalue(m.evaluate_manipulation, "_neg_cache")) <= 256, "negative cache has no hard bound")
    clock.now = 1000
    m.prune_caches()
    assert(count(positive) == 0)
    assert(count(upvalue(m.evaluate_manipulation, "_neg_cache")) == 0)
end)

test("cache TTLs and resumed scan progress stay unchanged", function()
    local m, clock = manip_fixture()
    local origin, target = { x = 0, y = 0, z = 0 }, { x = 10, y = 0, z = 0 }
    clock.visible = function(x) return x ~= 0 end
    assert(m.evaluate_manipulation(origin, target).state == "ready")
    clock.now = 219
    assert(m.evaluate_manipulation(origin, target).cached == true)
    clock.now = 220
    assert(not m.evaluate_manipulation(origin, target).cached)
    m.clear_peek_cache()
    clock.visible = function() return false end
    local done = false
    for i = 1, 100 do
        clock.now = clock.now + 16
        local result = m.evaluate_manipulation(origin, target, { ray_budget = 24 })
        if result.state == "blocked" then done = true; break end
    end
    assert(done, "active scan cursor was discarded")
    clock.now = clock.now + 159
    assert(m.evaluate_manipulation(origin, target).cached == true)
    clock.now = clock.now + 1
    assert(not m.evaluate_manipulation(origin, target).cached)
end)

local function image_fixture()
    local c = { now = 0, serial = 0, live = {}, urls = {}, freed = {}, failed = {} }
    local api = {
        load_image = function(url)
            if c.urls[url] then return c.urls[url] end
            c.serial = c.serial + 1
            c.urls[url], c.live[c.serial] = c.serial, url
            return c.serial
        end,
        FreeImage = function(handle)
            assert(c.live[handle], "double free")
            c.urls[c.live[handle]] = nil
            c.live[handle] = nil
            c.freed[handle] = true
        end,
        image_failed = function(handle) return c.failed[handle] == true end,
        image_loaded = function() return true end,
        image = function(handle) assert(c.live[handle], "drawing a freed handle") end,
    }
    local assets = {
        item_png = function(id) return "https://test/" .. id end,
        roblox_thumb = function(id) return "https://thumb/" .. id end,
        asset_delivery = function(id) return "https://delivery/" .. id end,
    }
    return c, api, assets
end

test("shared image handles survive eviction of one logical key", function()
    local c, api, assets = image_fixture()
    local m = load_module("core/image_cache", { ["game.asset_urls"] = assets, ["core.debug"] = quiet },
        { draw = api, utility = { get_tick_count = function() return c.now end } })
    m.preload("first", "https://test/shared")
    m.preload("second", "https://test/shared")
    c.now = 1000
    m.ensure("second", "https://test/shared")
    c.now = 60000
    m.prune()
    assert(m.state("first") == "none")
    assert(count(c.live) == 1 and not c.freed[1], "one alias freed another alias's texture")
    assert(m.draw_fit("second", 0, 0, 16, 16))
    c.now = 120000
    m.prune()
    assert(count(c.live) == 0 and c.freed[1], "last owner did not free texture")
end)

test("capacity eviction does not invalidate a shared image still in use", function()
    local c, api, assets = image_fixture()
    local m = load_module("core/image_cache", { ["game.asset_urls"] = assets, ["core.debug"] = quiet },
        { draw = api, utility = { get_tick_count = function() return c.now end } })
    m.preload("old", "https://test/shared")
    c.now = 1
    m.preload("active", "https://test/shared")
    for i = 1, 383 do
        c.now = i + 1
        m.preload("item" .. i, "https://test/item" .. i)
        m.ensure("active", "https://test/shared")
    end
    assert(m.state("old") == "none")
    assert(m.draw_fit("active", 0, 0, 16, 16), "eviction invalidated the active alias")
end)

test("announcer textures obey the image cache limit and idle cleanup", function()
    local c, api, assets = image_fixture()
    local m = load_module("core/image_cache", { ["game.asset_urls"] = assets, ["core.debug"] = quiet },
        { draw = api, utility = { get_tick_count = function() return c.now end } })
    for i = 1, 500 do
        c.now = i
        m.preload("anime_baddie:" .. i, "https://test/sprite" .. i)
    end
    assert(count(c.live) <= 384, "pinned sprites bypassed limit")
    c.now = 61000
    m.prune()
    assert(count(c.live) == 0)
end)

test("announcer installation does not preload disabled sprites", function()
    local modules = setmetatable({}, { __index = function() return {} end })
    local loads = 0
    modules["core.image_cache"] = { preload = function() loads = loads + 1 end }
    modules["game.anime_announcer_data"] = {
        load_remote = function() end,
        characters = {{ id = "test", expressions = { neutral = "neutral.png" }, urls = function() return {} end }},
    }
    load_module("features/utility/anime_announcer", modules).install()
    assert(loads == 0, "disabled feature eagerly loaded sprites")
end)

local function map_fixture()
    local c, api, assets = image_fixture()
    c.disk = 0
    local img = { Image = "rbxassetid://123" }
    assets.roblox_thumbnails_api = function(id) return "https://api/" .. id end
    assets.map_png = function(id) return "https://map/" .. id end
    assets.map_crop_urls = function(...) return { "https://crop/" .. table.concat({...}, ":") } end
    local modules = {
        ["game.asset_urls"] = assets, ["core.debug"] = quiet,
        ["core.config_store"] = { get_config_path = function() return "mock" end },
        ["core.env"] = {
            get_local_player = function() end,
            safe_call = function(fn) return fn() end,
            get_replicated_storage = function() return { UIs = { Main = { Map = { Frame = { Map = img } } } } } end,
        },
    }
    local m = load_module("game/map_image", modules, {
        draw = api, game = { PlaceId = 1 },
        utility = {
            get_tick_count = function() return c.now end,
            HttpGet = function(url)
                return '{"state":"Completed","imageUrl":"https://cdn/' .. url:match("(%d+)$") .. string.rep("x", 70) .. '"}'
            end,
        },
        io = { open = function()
            c.disk = c.disk + 1
            return { close = function() end, read = function() return "\137PNG\13\10\26\10" end }
        end },
        os = { remove = function() end },
    })
    return m, c, img
end

test("ready map polling performs no filesystem work", function()
    local m, c = map_fixture()
    m.ensure()
    local initial_disk = c.disk
    for i = 1, 1000 do c.now = i * 16; assert(m.ready()) end
    assert(c.disk == initial_disk, "ready map repeatedly probes disk")
end)

test("map fallback frees failed native handles", function()
    local m, c = map_fixture()
    local first = m.ensure()
    c.failed[first] = true
    local second = m.ensure()
    assert(second ~= first and c.freed[first], "failed image handle leaked")
    c.failed[second] = true
    assert(m.ensure() == nil)
    assert(count(c.live) == 0, "exhausted fallback left native handles")
    local serial = c.serial
    c.now = 29999
    m.ensure()
    assert(c.serial == serial, "map retry delay changed")
    c.now = 30000
    assert(m.ensure() ~= nil)
end)

test("map asset replacement and crop eviction release textures", function()
    local m, c, img = map_fixture()
    local first = m.ensure()
    for i = 1, 100 do
        c.now = i * 16
        m.draw_centered({ img_size = 1400, view_x = i * 20, view_z = 0 }, { x = 0, y = 0, w = 300, h = 300 })
        assert(count(c.live) <= 13, "crop cache exceeded 12 crops plus full map")
    end
    img.Image = "rbxassetid://456"
    c.now = 3000
    assert(m.ensure() ~= first and c.freed[first], "asset resolver overwrote loaded identity before invalidation")
    assert(count(c.live) == 1, "old crops survived map change")
    m.invalidate()
    assert(count(c.live) == 0)
end)

local function gc_fixture()
    local c = { now = 5000, refreshes = 0, warms = 0, found = 0, patches = 0 }
    local m = load_module("game/gc_weapon_mods", {
        ["core.debug"] = quiet, ["core.env"] = { get_local_player = function() return {} end },
    }, {
        utility = { get_tick_count = function() return c.now end },
        game = { place_id = 1, workspace = { Address = 123 } },
        refreshgc = function() c.refreshes = c.refreshes + 1 end,
        getgc = function() c.warms = c.warms + 1; return c.found end,
        applygc = function(...)
            assert(select("#", ...) == 1, "applygc expects one payload table")
            assert((...).RecoilMult == 0.5, "wrong applygc payload")
            c.patches = c.patches + 1
            return 1
        end,
    })
    return m, c
end

test("failed GC warmups honor existing apply and refresh intervals", function()
    local m, c = gc_fixture()
    m.apply_weapon({ RecoilMult = 0.5 })
    for i = 1, 28 do c.now = 5000 + i * 16; m.apply_weapon({ RecoilMult = 0.5 }) end
    assert(c.warms == 1 and c.refreshes == 1, "failed warmups run each frame")
    c.now = 5450
    m.apply_weapon({ RecoilMult = 0.5 })
    assert(c.warms == 2 and c.refreshes == 1, "no-nodes result bypassed refresh interval")
    c.now = 10000
    m.apply_weapon({ RecoilMult = 0.5 })
    assert(c.refreshes == 2)
end)

test("GC apply uses the documented payload without changing successful cadence", function()
    local m, c = gc_fixture()
    c.found = 1
    assert(m.apply_weapon({ RecoilMult = 0.5 }))
    c.now = 5449
    assert(not m.apply_weapon({ RecoilMult = 0.5 }))
    c.now = 5450
    assert(m.apply_weapon({ RecoilMult = 0.5 }))
    assert(c.patches == 2)
end)

test("frame maintenance runs even while the startup intro is active", function()
    local images, searches, updates = 0, 0, 0
    local modules = {
        ["menu.tabs"] = { init = function() return true end, update = function() updates = updates + 1 end },
        ["core.debug"] = { tick_frame = function() end, frame_count = function() return 1 end },
        ["core.notify"] = {}, ["ui.custom_menu"] = { init = function() end },
        ["ui.startup_intro"] = {
            init = function() end, is_active = function() return true end,
            should_reveal_menu = function() return false end, draw = function() end,
        },
        ["core.api_aliases"] = {}, ["core.feature_bind"] = { tick = function() end },
        ["core.aim_key"] = { tick = function() end }, ["core.overlay_theme"] = {},
        ["core.settings"] = { begin_frame = function() end },
        ["core.image_cache"] = { prune = function() images = images + 1 end },
        ["core.manip_math"] = { prune_caches = function() searches = searches + 1 end },
        ["core.entity_props"] = { ensure_api_aliases = function() end },
    }
    local app = load_module("app", modules)
    assert(app.init())
    app.on_frame()
    assert(images == 1 and searches == 1 and updates == 0)
end)

print(string.format("Memory regressions: %d passed, %d failed", passed, failed))
assert(failed == 0, "memory regressions failed")
