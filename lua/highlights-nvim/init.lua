local utils = require("highlights-nvim.utils")

local M = {}

M.config = {
    customizations = {},
    links          = {}
}

local colorschemes = {
    catppuccin = {
        pattern = "catppuccin*",
        palette = function()
            return require("catppuccin.palettes").get_palette()
        end
    },
    tokyonight = {
        pattern = "tokyonight*",
        palette = function()
            return require("tokyonight.colors").setup()
        end
    }
}

local function deep_merge(t1, t2)
    for k, v in pairs(t2) do
        if type(v) == 'table' and type(t1[k]) == 'table' then
            deep_merge(t1[k], v)
        else
            t1[k] = v
        end
    end

    return t1
end

local function resolve_color(group, hl, palette)
    local function resolve_attr(id)
        if id and string.match(id, "^#") then
            return id
        end

        if id and string.find(id, "|", 1, true) then
            local parts = vim.split(id, "|")

            return utils.blend(
                resolve_attr(parts[1]),
                resolve_attr(parts[2]),
                0.5
            )
        end

        if palette and not palette[id] then
            vim.notify(string.format("highlights-nvim: Could not find color %q", id), vim.log.levels.WARN)
            return nil
        end

        if not palette or not id then
            vim.notify(string.format("highlights-nvim: No palette available to resolve color %q", id),
                vim.log.levels.WARN)
            return nil
        end

        return palette[id]
    end

    local current_hl = utils.get_hl(group)

    current_hl.bg = current_hl.bg and string.format("#%06x", current_hl.bg)
    current_hl.fg = current_hl.fg and string.format("#%06x", current_hl.fg)

    hl.fg = hl.fg and resolve_attr(hl.fg)
    hl.bg = hl.bg and resolve_attr(hl.bg)

    return vim.tbl_deep_extend("force", current_hl, hl)
end

local function apply_customizations(customizations, colorscheme)
    for group, hl in pairs(customizations) do
        if colorschemes[group] then
            apply_customizations(customizations[group], group)
        else
            local palette = colorscheme and colorschemes[colorscheme].palette() or nil

            local new_hl = resolve_color(group, hl, palette)

            if new_hl then
                vim.api.nvim_set_hl(0, group, new_hl)
            else
                vim.notify(string.format("highlights-nvim: Could not resolve highlight for %q", group),
                    vim.log.levels.WARN)
            end
        end
    end
end

local apply_links = function(links)
    for src, dst in pairs(links) do
        vim.api.nvim_set_hl(0, src, { link = dst })
    end
end

M.apply_highlights = function()
    apply_links(M.config.links)
    apply_customizations(M.config.customizations)
end

M.add = function(opts)
    if not opts then return end

    M.config = deep_merge(M.config, opts)

    M.apply_highlights()
end

return M
