# Neovim Cheat Sheet

## Quick Reference - Most Used Commands

| Command | What It Does |
| --- | --- |
| `<space>fd` | **Find file** (fuzzy search) |
| `<space>fg` | **Find text** in entire project (grep) |
| `<space>fb` | List open buffers |
| `gd` | **Go to definition** |
| `<C-o>` | **Jump back** to previous location |
| `<space>a` | **Mark file** in Harpoon |
| `<space>m` | **Harpoon menu** (see marked files) |
| `<space>q` | **Close buffer** |
| `<space>ch` | **Open this cheatsheet** |
| `*` | Search word under cursor |
| `n` / `N` | Next/previous search result |

---

## 1. Installed Plugins & Purpose

| Plugin | Purpose |
| --- | --- |
| `nvim-lua/plenary.nvim` | Required utility functions for many Neovim plugins |
| `neovim/nvim-lspconfig` | LSP (Language Server Protocol) configuration |
| `williamboman/mason.nvim` | LSP, DAP, and formatter installer |
| `williamboman/mason-lspconfig.nvim` | Integration of Mason with LSP servers |
| `WhoIsSethDaniel/mason-tool-installer.nvim` | Ensure tools like formatters / linters are installed |
| `b0o/SchemaStore.nvim` | JSON/YAML schemas for LSP autocomplete |
| `folke/neodev.nvim` | Lua development support for Neovim |
| `hrsh7th/nvim-cmp` | Autocomplete engine |
| `hrsh7th/cmp-nvim-lsp` | LSP source for nvim-cmp |
| `hrsh7th/cmp-buffer` | Buffer source for autocomplete |
| `hrsh7th/cmp-path` | Path source for autocomplete |
| `saadparwaiz1/cmp_luasnip` | Snippet support for autocomplete |
| `L3MON4D3/LuaSnip` | Snippet engine |
| `onsails/lspkind.nvim` | Icons for autocomplete entries |
| `nvim-treesitter/nvim-treesitter` | Syntax highlighting, code parsing, incremental selection |
| `romgrk/barbar.nvim` | Tabline / buffer line |
| `nvim-lualine/lualine.nvim` | Statusline |
| `j-hui/fidget.nvim` | LSP progress display |
| `nvim-tree/nvim-tree.lua` | File explorer tree |
| `nvim-tree/nvim-web-devicons` | Icons for files |
| `nvim-telescope/telescope.nvim` | Fuzzy finding and search |
| `nvim-telescope/telescope-fzf-native.nvim` | FZF integration for Telescope |
| `nvim-telescope/telescope-ui-select.nvim` | UI select menus for Telescope |
| `nvim-telescope/telescope-smart-history.nvim` | History for Telescope searches |
| `kkharji/sqlite.lua` | SQLite interface for Telescope / plugins |
| `mfussenegger/nvim-dap` | Debug Adapter Protocol |
| `rcarriga/nvim-dap-ui` | UI for DAP |
| `leoluz/nvim-dap-go` | Go language debugging support |
| `theHamsta/nvim-dap-virtual-text` | Display debug info inline |
| `nvim-neotest/nvim-nio` | Test runner integration |
| `ThePrimeagen/harpoon` | Quick file navigation / marks |
| `stevearc/conform.nvim` | Autoformatting support |
| `tpope/vim-dadbod` | Database client |
| `kristijanhusak/vim-dadbod-ui` | UI for database plugin |
| `kristijanhusak/vim-dadbod-completion` | SQL completion |
| `tjdevries/express_line.nvim` | Alternative statusline (optional) |
| `iamcco/markdown-preview.nvim` | Markdown preview in browser |
| `MeanderingProgrammer/render-markdown.nvim` | Live markdown rendering in buffer |
| `folke/noice.nvim` | UI for messages, cmdline and popupmenu |
| `MunifTanjim/nui.nvim` | UI component library for Noice |
| `windwp/nvim-ts-autotag` | Auto-close HTML/JSX tags |

---

## 2. Keybindings / Shortcuts

### 2.1. Terminal
| Key | Action |
| --- | --- |
| `<leader>t` | Open terminal in bottom 5-line split |

### 2.2. LSP & Autocomplete
| Key | Action |
| --- | --- |
| `gd` | Go to definition |
| `gD` | Go to declaration |
| `gr` | References |
| `gT` | Type definition |
| `K` | Hover documentation |
| `<space>cr` | Rename symbol |
| `<space>ca` | Code actions |
| `<space>co` | Organize imports (TS/JS only) |
| `<space>ci` | Add missing imports (TS/JS only) |
| `<space>cI` | Manually add missing imports |
| `<space>wd` | Document symbols |
| `<space>ww` | Workspace diagnostics |
| `<leader>e` | Opens floating diagnostics window |
| `<space>f` | Format buffer (autoformat on save via `conform.nvim`) |
| `<C-Space>` | Manually trigger autocomplete |

### 2.3. Telescope (Fuzzy Finder)
| Key | Action |
| --- | --- |
| `<space>fd` | Find files in cwd |
| `<space>ft` | Find Git-tracked files in current directory |
| `<space>fh` | Search help tags |
| `<space>fg` | Ripgrep search in project |
| `<space>fb` | Open buffer list |
| `<space>/` | Fuzzy search in current buffer |
| `<space>gw` | Search string under cursor |

### 2.4. DAP / Debugging
| Key | Action |
| --- | --- |
| `<space>b` | Toggle breakpoint |
| `<space>gb` | Run to cursor |
| `<space>?` | Evaluate variable under cursor |
| `<F1>` | Continue |
| `<F2>` | Step into |
| `<F3>` | Step over |
| `<F4>` | Step out |
| `<F5>` | Step back |
| `<F13>` | Restart |

### 2.5. Harpoon (Quick file navigation)
| Key | Action |
| --- | --- |
| `<space>a` | Add current file to Harpoon marks |
| `<space>m` | Toggle Harpoon quick menu |
| `<space>j` | Jump to Harpoon mark 1 |
| `<space>k` | Jump to Harpoon mark 2 |
| `<space>l` | Jump to Harpoon mark 3 |
| `<space>;` | Jump to Harpoon mark 4 |
| `<space>n` | Next Harpoon mark |
| `<space>p` | Previous Harpoon mark |

### 2.6. Barbar (Buffer Navigation)
| Key | Action |
| --- | --- |
| `<C-Tab>` | Next buffer |
| `<C-S-Tab>` | Previous buffer |
| `<leader>>` | Move buffer right |
| `<leader><` | Move buffer left |
| `<space>q` | **Close current buffer** (quick!) |
| `<leader>bc` | Close current buffer |
| `<leader>bo` | Close other buffers |
| `<leader>1..9` | Go to buffer 1-9 |
| `<leader>bp` | Pin/unpin buffer |

### 2.7. Navigation / Editing
| Key | Action |
| --- | --- |
| `<c-j> / <c-k> / <c-h> / <c-l>` | Navigate splits |
| `<left> / <right>` | Navigate tabs |
| `<M-,> / <M-.>` | Resize splits horizontally |
| `<M-t> / <M-s>` | Resize splits vertically |
| `<M-j> / <M-k>` | Move current line down/up (or diff navigation) |
| `<CR>` | Clear search highlight if active, else enter |
| `%` / `g%` / `[ %` / `] %` | Jump to matching pairs (including multi plugin navigation) |
| `[ ` / `] ` | Add empty line above / below cursor |
| `Y` | Yank to end of line (`y$`) |
| `gp` | **Smart paste** (paste and auto-add missing imports for JS/TS) |
| `gP` | **Smart paste before** (paste before cursor and auto-add missing imports) |
| `<space>ch` | **Open this cheatsheet** (formatted in browser) |

### 2.8. Markdown
| Key | Action |
| --- | --- |
| `<leader>mp` | **Markdown Preview** - Open in web browser (full HTML rendering) |
| `<leader>ms` | Stop markdown preview |
| `<leader>md` | Toggle in-editor rendering (conceals markup, styles headers) |

### 2.9. Comments & Snippets
| Key | Action |
| --- | --- |
| `gcc` | Toggle comment line |
| `gc` | Toggle comment |
| `<Plug>luasnip-expand-repeat` | Repeat last snippet node expansion |
| `<Plug>luasnip-delete-check` | Remove current snippet from jumplist |

### 2.10. Plenary Test
| Key | Action |
| --- | --- |
| `<Plug>PlenaryTestFile` | Test current file with Plenary |

---

## 3. General Neovim Commands

| Command | Description |
| --- | --- |
| `:e <file>` | Open file |
| `:w` | Save file |
| `:w <file>` | Save as new file |
| `:q` | Quit window |
| `:q!` | Quit without saving |
| `:wq` / `:x` | Save and quit |
| `:bn` / `:bp` | Next / previous buffer |
| `:bd` | Close buffer |
| `:ls` | List buffers |
| `:split` / `:vsplit` | Horizontal / vertical split |
| `Ctrl-w h/j/k/l` | Move between splits |
| `Ctrl-w q` | Close current split |
| `/pattern` | Search forward |
| `?pattern` | Search backward |
| `n` / `N` | Repeat search |
| `:%s/old/new/gc` | Replace with confirmation |
| `m{letter}` | Set mark |
| `'{letter}` | Jump to mark line |
| `` `{letter}` `` | Jump to exact mark |
| `u` / `Ctrl-r` | Undo / redo |
| `v` / `V` / `Ctrl-v` | Visual / line / block selection |
| `y` / `d` / `c` | Yank / delete / change selection |
| `>` / `<` | Indent / un-indent selection |
| `:set number` / `:set relativenumber` | Show line numbers |
| `:noh` | Clear search highlights |
| `:checkhealth` | Check Neovim & plugin setup |
| `:source %` | Reload current file (useful for config) |

