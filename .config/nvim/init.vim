local home = os.getenv("HOME")
package.path = home .. "/.config/nvim/?.lua;" .. package.path

-- vim-plug
local Plug = vim.fn['plug#']

vim.call('plug#begin', home .. '/.config/nvim/plugged')

-- FILE TREE
Plug('nvim-tree/nvim-tree.lua')
Plug('nvim-tree/nvim-web-devicons')

-- BARBAR
Plug('romgrk/barbar.nvim')

-- STATUSLINE
Plug('nvim-lualine/lualine.nvim')

-- TREESITTER
Plug('nvim-treesitter/nvim-treesitter', { ['do'] = ':TSUpdate' })

-- LSP
Plug('neovim/nvim-lspconfig')

vim.call('plug#end')

-- ============================================================
--  NOW load plugin configs (after plug#end)
-- ============================================================

-- Treesitter (must be AFTER plugins load)
local ts_install = require("nvim-treesitter.install")
ts_install.prefer_git = true
ts_install.compilers = { "gcc", "clang" }

-- Your custom config
require("common")
require("theme").apply()
require("nvimtree")
require("barbar-config")
require("lua_line")
require("treesitter")
require("lsp")

