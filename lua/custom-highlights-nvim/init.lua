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

local function resolve_group(group, hl, scheme, palette)
    local resolve_attr = function(id)
        if not id then return nil end

        if string.match(id, "^#") then
            return id
        end

        if not palette[id] then
            vim.notify(string.format("custom-highlights-nvim: No color %q available in colorscheme %q", id, scheme),
                "warn")
        end

        return palette[id]
    end

    local current_hl = vim.api.nvim_get_hl(0, { name = group })

    if current_hl.link then
        return resolve_group(current_hl.link, hl, scheme, palette)
    end

    if current_hl.bg then
        current_hl.bg = string.format("#%06x", current_hl.bg)
    end

    if current_hl.fg then
        current_hl.fg = string.format("#%06x", current_hl.fg)
    end

    local resolved_hl = vim.tbl_deep_extend("force", hl, {
        fg = resolve_attr(hl.fg),
        bg = resolve_attr(hl.bg),
    })

    return vim.tbl_deep_extend("force", current_hl, resolved_hl)
end

local apply_customizations = function(scheme, highlights)
    local palette = colorschemes[scheme].palette()

    for group, hl in pairs(highlights) do
        local new_hl = resolve_group(group, hl, scheme, palette)

        vim.api.nvim_set_hl(0, group, new_hl)
    end
end

local apply_links = function(links)
    for src, dst in pairs(links) do
        vim.api.nvim_set_hl(0, src, { link = dst })
    end
end

M.apply_highlights = function()
    apply_links(M.config.links)

    local current_colorscheme = vim.g.colors_name

    if not current_colorscheme then return end

    for name, c in pairs(colorschemes) do
        if string.match(current_colorscheme, c.pattern) then
            local highlights = M.config.customizations[name]

            if highlights then
                apply_customizations(name, highlights)
                break
            end
        end
    end
end

M.add = function(opts)
    if not opts then return end

    M.config = deep_merge(M.config, opts)
end

return M
