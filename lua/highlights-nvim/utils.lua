local M = {}

M.ensure_number = function(color)
    if type(color) == "string" then
        return tonumber(color:gsub("#", ""), 16) or 0
    elseif type(color) ~= "number" then
        return 0
    end

    return color
end

M.blend = function(what, into, amount)
    amount = amount or 0.5
    amount = math.max(0, math.min(1, amount))

    into = M.ensure_number(into)
    what = M.ensure_number(what)

    -- Clamp to valid color range
    into = math.max(0, math.min(0xFFFFFF, into))
    what = math.max(0, math.min(0xFFFFFF, what))

    -- Extract RGB components
    local bg_r = math.floor(into / 65536) % 256
    local bg_g = math.floor(into / 256) % 256
    local bg_b = into % 256

    local fg_r = math.floor(what / 65536) % 256
    local fg_g = math.floor(what / 256) % 256
    local fg_b = what % 256

    -- Blend components
    local r = math.floor(bg_r + (fg_r - bg_r) * amount)
    local g = math.floor(bg_g + (fg_g - bg_g) * amount)
    local b = math.floor(bg_b + (fg_b - bg_b) * amount)

    return string.format("#%02x%02x%02x", r, g, b)
end

M.get_hl = function(name)
    local hl = vim.api.nvim_get_hl(0, { name = name })

    if hl.link then
        return M.get_hl(hl.link)
    end

    return hl
end

M.adjust_brightness = function(color, amount)
    color = M.ensure_number(color)

    -- Clamp inputs to valid ranges
    color = math.max(0, math.min(0xFFFFFF, color))
    amount = math.max(0, math.min(10, amount or 1))

    -- Extract RGB components
    local r = math.floor(color / 65536) % 256
    local g = math.floor(color / 256) % 256
    local b = color % 256

    -- Apply brightness adjustment
    r = math.min(255, math.floor(r * amount))
    g = math.min(255, math.floor(g * amount))
    b = math.min(255, math.floor(b * amount))

    -- Combine back to hex
    return r * 65536 + g * 256 + b
end

return M
