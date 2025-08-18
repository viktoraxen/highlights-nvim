local M = {}

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

    for _, h in ipairs(highlights) do
        local group = h[1]
        local hl = h[2]
        local new_hl = resolve_group(group, hl, scheme, palette)

        vim.api.nvim_set_hl(0, group, new_hl)
    end
end

local apply_links = function(links)
    for _, l in ipairs(links) do
        vim.api.nvim_set_hl(0, l.src, { link = l.dst })
    end
end

M.setup = function(opts)
    vim.api.nvim_create_augroup('CustomHighlights', { clear = true })

    local autocmd_callback = function()
        apply_links(opts.links)

        local current_colorscheme = vim.g.colors_name

        if not current_colorscheme then return end

        for name, c in pairs(colorschemes) do
            if string.match(current_colorscheme, c.pattern) then
                local highlights = opts.customizations[name]

                if highlights then
                    apply_customizations(name, highlights)
                    break
                end
            end
        end
    end

    vim.api.nvim_create_autocmd('ColorScheme', {
        group    = 'CustomHighlights',
        pattern  = "*",
        desc     = "Apply links and customizations.",
        callback = autocmd_callback
    })

    autocmd_callback()
end

return M
