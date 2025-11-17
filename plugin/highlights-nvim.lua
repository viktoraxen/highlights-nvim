vim.api.nvim_create_augroup('CustomHighlights', { clear = true })

vim.api.nvim_create_autocmd('ColorScheme', {
    group    = 'CustomHighlights',
    pattern  = "*",
    desc     = "Apply links and customizations.",
    callback = require('highlights-nvim').apply_highlights
})
