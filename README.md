# nvim-search-mode

Modal `next` and `prev` jumping.

These days neovim has a lot of useful features that jump you back and forth
between relevant lines. Jumping between snippet fields,
`vim.diagnostic.goto_next()`, `gitsigns.next_hunk()`, good old builtin vim
search, etc...

This plugin puts these and more behing a single leader key.

## :rocket: Usage

- Jump to next/previous diagnostic with `gnd`/`gpd`.
- Keep jumping in diagnostic mode with `n` and `N` like default vim search.
- Change mode with `gn<mode>`/`gp<mode>`.
- Integrate any next/prev with lua!
- Call `:NextModeReset` to reset to the search mode

## :package: Installation

### [packer.nvim](https://github.com/wbthomason/packer.nvim)

```lua
use 'rwblokzijl/nvim-search-mode'
```

### [vim-plug](https://github.com/junegunn/vim-plug)

```vim
Plug 'rwblokzijl/nvim-search-mode'
```

## :gear: Configuration

### Simple configuration

The following example configures lsp diagnostics, gitsigns hunk jumping and
luasnip jumping.

```lua
local ls = require "luasnip"

require('nvim-next-mode').setup({
  search_modes = {
    lsp_diagnostics = {
      mode_leader = "d", -- gnd/gpd
      next_callback = vim.diagnostic.goto_next,
      prev_callback = vim.diagnostic.goto_prev,
    },
    git_hunks = {
      mode_leader = "h", -- gnh/gph
      next_callback = function () vim.schedule(function() require('gitsigns').next_hunk() end) end,
      prev_callback = function () vim.schedule(function() require('gitsigns').prev_hunk() end) end,
    },
    luasnip = {
      mode_leader = "s", -- gns/gps
      mappings = {
        next = {
          { modes = {'n', 'i', 's'}, key = "<c-j>" }, -- specify mode specific mappings
        },
        prev = {
          { modes = {'n', 'i', 's'}, key = "<c-k>" },
        },
      },
      next_callback = function() if ls.expand_or_jumpable() then ls.expand_or_jump() end end,
      prev_callback = function() if ls.jumpable(-1) then ls.jump(-1) end end,
    }
  }
})
```

### Default configuration

The default configuration is as follows and can be overwritten.

```lua
require('nvim-next-mode').setup({
  mappings = {
    next = {
      { modes = {'n'}, key = "n" } -- for jumping to the next item in the mode
    },
    prev = {
      { modes = {'n'}, key = "N" } -- for jumping to the previous item
    },
    leader_next = {
      { modes = {'n'}, key = "gn" } -- leader for switching modes and jumping to next
    },
    leader_prev = {
      { modes = {'n'}, key = "gp" } -- leader for switching modes and jumping to prev
    },
  },
  search_modes = { -- buildin search mode is always enabled
    search = {
      next_callback = function () vim.cmd 'silent! norm! n' end,
      prev_callback = function () vim.cmd 'silent! norm! N' end,
    },
  },
  default_mode = "search", -- this is the default mode
}
```

### Unbreak search mode

To automatically return to search mode, add the following mappings for `*`, `#`, `/` and `?`:

```vim
nnoremap * :NextModeReset<CR>/\<<C-R>=expand('<cword>')<CR>\><CR>
nnoremap # :NextModeReset<CR>?\<<C-R>=expand('<cword>')<CR>\><CR>
nnoremap / :NextModeReset<CR>/
nnoremap ? :NextModeReset<CR>?
```

### Show mode on [lualine](https://github.com/nvim-lualine/lualine.nvim)

```lua
lualine_x = {require('nvim-next-mode').mode, ...},
```

