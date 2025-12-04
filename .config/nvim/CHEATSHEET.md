# Neovim Cheat Sheet

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
| `coder/claudecode.nvim` | Claude AI code integration for prompts, explanations, and diffs |

---

## 2. Keybindings / Shortcuts

### 2.1. Terminal
| Key | Action |
| --- | --- |
| `<leader>t` | Open terminal in bottom 5-line split |
| `<Esc>` (terminal mode) | Exit terminal insert mode back to normal mode |

### 2.2. LSP & Autocomplete
| Key | Action |
| --- | --- |
| `gd` | Go to definition |
| `gD` | Go to declaration |
| `gr` | References |
| `gri` | Implementation |
| `grt` | Type definition |
| `K` | Hover documentation |
| `<space>cr` | Rename symbol |
| `<space>ca` | Code actions |
| `<space>wd` | Document symbols |
| `<space>ww` | Workspace diagnostics |
| `<space>e` | Opens floating diagnostics window |
| `<space>f` | Format buffer (autoformat on save via `conform.nvim`) |
| `[d` / `]d` | Previous / Next diagnostic |
| `[D` / `]D` | First / Last diagnostic in buffer |

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
| `<M-h><M-m>` | Add current file to Harpoon marks |
| `<M-h><M-l>` | Toggle Harpoon quick menu |

### 2.6. Barbar (Buffer Navigation)
| Key | Action |
| --- | --- |
| `<Tab>` | Next buffer |
| `<S-Tab>` | Previous buffer |
| `<leader>>` | Move buffer right |
| `<leader><` | Move buffer left |
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

### 2.8. Comments & Snippets
| Key | Action |
| --- | --- |
| `gcc` | Toggle comment line |
| `gc` | Toggle comment |
| `<Plug>luasnip-expand-repeat` | Repeat last snippet node expansion |
| `<Plug>luasnip-delete-check` | Remove current snippet from jumplist |

### 2.9. Plenary Test
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

