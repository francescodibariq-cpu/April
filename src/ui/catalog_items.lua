--[[
  Shared catalog item constructors used by ui.catalog_* tab builders.
]]

local gpu_chams = April.require("core.gpu_chams")

local M = {}

function M.cb(id, label, default, color, gate, extra)
    local item = { type = "checkbox", id = id, label = label, default = default == true, color = color, gate = gate }
    if type(extra) == "table" then
        for k, v in pairs(extra) do item[k] = v end
    end
    return item
end

function M.kb(id, label, default, gate, extra)
    local item = { type = "keybind", id = id, label = label, default = default == true, gate = gate }
    if type(extra) == "table" then
        for k, v in pairs(extra) do item[k] = v end
    end
    return item
end

function M.sl(id, label, minv, maxv, default, float, gate, extra)
    local item = {
        type = "slider",
        id = id,
        label = label,
        min = minv,
        max = maxv,
        default = default,
        float = float == true,
        fmt = float and "%.2f" or "%d",
        gate = gate,
    }
    if type(extra) == "table" then
        for k, v in pairs(extra) do
            item[k] = v
        end
    end
    return item
end

function M.combo(id, label, options, default, gate, extra)
    local item = { type = "combo", id = id, label = label, options = options, default = default or 0, gate = gate }
    if type(extra) == "table" then
        for k, v in pairs(extra) do
            item[k] = v
        end
    end
    return item
end

function M.multi(id, label, options, defaults, gate, extra)
    local item = { type = "multi", id = id, label = label, options = options, defaults = defaults, gate = gate }
    if type(extra) == "table" then
        for k, v in pairs(extra) do item[k] = v end
    end
    return item
end

function M.btn(id, label, gate)
    return { type = "button", id = id, label = label, gate = gate }
end

function M.sep(gate)
    return { type = "separator", gate = gate }
end

function M.label(text, dim, gate)
    return { type = "label", label = text, dim = dim, gate = gate }
end

function M.color(id, label_text, default, gate, override_idx)
    return {
        type = "color",
        id = id,
        label = label_text,
        default = default,
        gate = gate,
        color_override_idx = override_idx,
    }
end

function M.input(id, label_text, default, gate)
    return { type = "input", id = id, label = label_text, default = default or "", gate = gate }
end

function M.ak(key_id, label, gate)
    return { type = "aim_key", id = key_id, mode_id = key_id .. "_mode", label = label, gate = gate }
end

function M.hk(id, label, gate, default_vk)
    return { type = "hotkey", id = id, label = label, gate = gate, default = default_vk or 0x2D }
end

function M.from_toggles(list, gate)
    local out = {}
    for _, t in ipairs(list) do
        out[#out + 1] = M.cb(t.id, t.label, false, t.color, gate)
        if t.ring_id then
            out[#out + 1] = M.cb(t.ring_id, t.label .. " Range Ring", false, nil, gate)
        end
    end
    return out
end

function M.append(dst, src)
    for _, v in ipairs(src) do
        dst[#dst + 1] = v
    end
end

function M.toggle_labels(list)
    local labels = {}
    for i, t in ipairs(list) do
        labels[i] = t.label
    end
    return labels
end

-- GPU mesh chams block (see docs/API.md §15 — preset mode + glow color indices).
function M.mesh_chams_block(prefix, toggle_list, master)
    local chams_id = prefix .. "_chams"
    local chams_master = prefix .. "_chams_enabled"
    local mode_id = prefix .. "_chams_mode"
    local color_id = prefix .. "_chams_color"
    return {
        M.sep(master),
        M.label("Mesh Chams (GPU)", false, master),
        M.cb(chams_master, "Enable Mesh Chams", false, nil, master),
        M.multi(chams_id, "Cham Types", M.toggle_labels(toggle_list), {}, chams_master),
        M.combo(mode_id, "Chams Mode", gpu_chams.MODE_LABELS, 0, chams_master),
        M.combo(color_id, "Glow Preset", gpu_chams.COLOR_LABELS, 0, chams_master, {
            gate_any_combo = {
                { mode_id, { 2, 3 } },
            },
        }),
    }
end

return M
