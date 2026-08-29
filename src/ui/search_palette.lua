local theme = April.require("ui.gs_theme")
local input = April.require("ui.gs_input")
local widgets = April.require("ui.gs_widgets")
local anim = April.require("ui.gs_anim")
local icons = April.require("ui.gs_icons")
local state = April.require("ui.gs_state")
local catalog = April.require("ui.catalog")
local i18n = April.require("ui.i18n")

local M = {}

local QUERY_ID = "april_ui_search_query"
local MAX_RESULTS = 8
local entries = nil
local results = {}
local selected = 1
local open = false
local pending = nil
local last_query = nil
local focus_pending = false

local function lower(value)
    return tostring(value or ""):lower()
end

local function translated(value)
    return i18n.t(tostring(value or ""))
end

local function add_entry(out, entry, terms)
    local parts = {}
    local function add(value)
        if value ~= nil and tostring(value) ~= "" then
            parts[#parts + 1] = tostring(value)
        end
    end
    add(entry.label)
    add(entry.tab and entry.tab.label)
    add(entry.tab and entry.tab.title)
    add(entry.group and entry.group.title)
    add(entry.item and entry.item.id)
    add(entry.item and entry.item.type)
    if terms then
        for i = 1, #terms do add(terms[i]) end
    end
    entry.haystack = lower(table.concat(parts, " "))
    entry.label_lower = lower(entry.label)
    entry.order = #out + 1
    out[#out + 1] = entry
end

local function build_entries()
    local out = {}
    for tab_index, tab in ipairs(catalog.TABS) do
        add_entry(out, {
            kind = "Tab", label = translated(tab.title or tab.label),
            tab = tab, tab_index = tab_index,
        }, { tab.id, tab.description })

        local groups = catalog.groups_for(tab.id)
        for group_index, group in ipairs(groups) do
            add_entry(out, {
                kind = "Module", label = translated(group.title),
                tab = tab, tab_index = tab_index,
                group = group, group_index = group_index,
            })

            for item_index, item in ipairs(group.items or {}) do
                if item.type ~= "separator" and item.label then
                    local option_terms = {}
                    for _, option in ipairs(item.options or {}) do
                        option_terms[#option_terms + 1] = option
                        option_terms[#option_terms + 1] = translated(option)
                    end
                    local kind = (item.type == "checkbox" or item.type == "keybind")
                        and "Feature" or "Setting"
                    add_entry(out, {
                        kind = kind, label = translated(item.label),
                        tab = tab, tab_index = tab_index,
                        group = group, group_index = group_index,
                        item = item, item_index = item_index,
                    }, option_terms)
                end
            end
        end
    end
    entries = out
end

local function match_rank(entry, query)
    local q = lower(query):match("^%s*(.-)%s*$") or ""
    if q == "" then return nil end
    local cursor = 1
    for token in q:gmatch("%S+") do
        local found = entry.haystack:find(token, 1, true)
        if not found then return nil end
        cursor = cursor + found
    end
    if entry.label_lower == q then return 0 end
    if entry.label_lower:sub(1, #q) == q then return 10 end
    if entry.label_lower:find(" " .. q, 1, true) then return 20 end
    local label_pos = entry.label_lower:find(q, 1, true)
    if label_pos then return 30 + label_pos end
    return 100 + cursor
end

local function refresh_results()
    if not entries then build_entries() end
    local query = tostring(state.get(QUERY_ID, ""))
    if query == last_query then return end
    last_query = query
    results = {}
    for i = 1, #entries do
        local rank = match_rank(entries[i], query)
        if rank then
            results[#results + 1] = { entry = entries[i], rank = rank }
        end
    end
    table.sort(results, function(a, b)
        if a.rank == b.rank then return a.entry.order < b.entry.order end
        return a.rank < b.rank
    end)
    while #results > MAX_RESULTS do results[#results] = nil end
    selected = math.max(1, math.min(selected, #results))
end

function M.init()
    state.define(QUERY_ID, "")
end

function M.is_open()
    return open
end

function M.open()
    open = true
    entries = nil
    selected = 1
    last_query = nil
    state.set(QUERY_ID, "")
    focus_pending = true
end

function M.close()
    open = false
    focus_pending = false
    widgets.blur_text_input(QUERY_ID)
end

function M.toggle()
    if open then M.close() else M.open() end
end

function M.consume_selection()
    local value = pending
    pending = nil
    return value
end

local function choose(entry)
    pending = entry
    M.close()
end

local function breadcrumb(entry)
    if entry.kind == "Tab" then return translated("Open section") end
    local tab_name = translated(entry.tab.label or entry.tab.title)
    if entry.kind == "Module" then return tab_name end
    return tab_name .. "  /  " .. translated(entry.group.title)
end

function M.draw(center_x, top_y, menu_w)
    if not open then return end
    if focus_pending and not input.lmb then
        widgets.focus_text_input(QUERY_ID)
        focus_pending = false
    end
    refresh_results()

    if input.key_pressed(0x1B) then
        M.close()
        return
    end
    if #results > 0 then
        if input.key_pressed(0x28) then
            selected = selected % #results + 1
        elseif input.key_pressed(0x26) then
            selected = (selected - 2) % #results + 1
        end
        if input.key_pressed(0x09) then
            state.set(QUERY_ID, results[selected].entry.label)
            last_query = nil
            widgets.focus_text_input(QUERY_ID)
        elseif input.key_pressed(0x0D) then
            choose(results[selected].entry)
            return
        end
    end

    local scale = theme.SCALE or 1
    local pw = math.min(math.floor(570 * scale), menu_w - 36)
    local row_h = math.floor(36 * scale)
    local header_h = math.floor(48 * scale)
    local footer_h = math.floor(24 * scale)
    local result_count = #results
    local empty_h = math.floor(58 * scale)
    local ph = header_h + (result_count > 0 and result_count * row_h or empty_h) + footer_h
    local px = math.floor(center_x - pw * 0.5)
    local py = top_y

    widgets.block_under = false
    widgets.clip = nil
    widgets.rect(px, py, pw, ph, theme.OVERLAY, true, theme.CORNER)
    widgets.rect(px, py, pw, ph, theme.BORDER_HOT, false, theme.CORNER)
    widgets.rect(px + 1, py + 1, pw - 2, header_h - 1, theme.PANEL_RAISED, true, theme.CORNER)
    icons.draw("search", px + 22, py + math.floor(header_h * 0.5), theme.TEXT_DIM)
    widgets.text_field(px + 38, py + 10, pw - 50, header_h - 20,
        QUERY_ID, translated("Search features, modules, settings..."), "")

    local list_y = py + header_h
    if result_count == 0 then
        local query = tostring(state.get(QUERY_ID, ""))
        local message = query == "" and translated("Type to search every feature and module")
            or translated("No matching features or modules")
        widgets.text(px + 16, list_y + 18, message, theme.TEXT_DIM, theme.FONT_SMALL)
    else
        for i = 1, result_count do
            local entry = results[i].entry
            local iy = list_y + (i - 1) * row_h
            local hot = input.hover(px + 6, iy + 2, pw - 12, row_h - 4)
            local active = i == selected
            local emphasis = anim.transition("search-result:" .. entry.order, active or hot, 18)
            if emphasis > 0.01 then
                widgets.rect(px + 6, iy + 2, pw - 12, row_h - 4,
                    theme.alpha(active and theme.NAV_ACTIVE or theme.HOVER,
                        0.42 + emphasis * 0.30), true, theme.CORNER_SMALL)
            end
            if active then
                widgets.rect(px + 8, iy + 8, 2, row_h - 16, theme.ACCENT, true, 1)
            end
            widgets.text(px + 16, iy + 6, entry.label,
                active and theme.TEXT_ACTIVE or theme.TEXT, theme.FONT)
            local crumb = breadcrumb(entry)
            widgets.text(px + 16, iy + 21, crumb, theme.TEXT_DIM, theme.FONT_CAPTION)
            local kind_w = #entry.kind * math.max(5, theme.FONT_CAPTION * 0.52)
            widgets.text(px + pw - 16 - kind_w, iy + 11,
                translated(entry.kind), theme.TEXT_DIM, theme.FONT_CAPTION)
            if input.clicked(px + 6, iy + 2, pw - 12, row_h - 4) then
                choose(entry)
                return
            end
            if hot then selected = i end
        end
    end

    local footer_y = py + ph - footer_h
    widgets.rect(px + 1, footer_y, pw - 2, 1, theme.BORDER_SOFT, true)
    widgets.text(px + 14, footer_y + 6,
        translated("Tab autocomplete   Up/Down navigate   Enter open   Esc close"),
        theme.TEXT_DIM, theme.FONT_CAPTION)
    widgets.block_under = true
end

return M
