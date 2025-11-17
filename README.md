# Custom Highlights for Neovim

Easy configuration for highlight groups in Neovim. Allows for globally linking highlight groups to other highlight groups, and manually setting colors from each colorschemes palette separately.

## Install

### Lazy

```lua
return {
    "viktoraxen/highlights-nvim",
    opts = { ... }
}
```

## Configuration

### Links

Linking highlight groups is done by setting the `links` field in `opts`.

```lua
opts = {
    links = {
        NormalFloat = "Normal",
        FloatBorder = "Title",
    }
}
```

### Colorschemes

Changing a highlight group for a specific colorscheme is done by changing the `customizations.<colorscheme_name>` fields in `opts`. Only works for supported colorschemes.

```lua
opts = {
    customizations = {
        catppuccin = {
            -- All fields (fg, bg, italic) are optional, omitting one will leave it unchanged
            WinSeparator, { fg = 'crust', bg = 'surface0', italic = false }
        }
    }
}
```

## Supported colorschemes

 * Catppuccin: [GitHub](https://github.com/catppuccin/nvim), [Palette](https://catppuccin.com/palette/)
 * Tokyonight: [GitHub](https://github.com/folke/tokyonight.nvim), For palette run `require("tokyonight.colors").setup()`
