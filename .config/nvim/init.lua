local home = os.getenv("HOME")
package.path = home .. "/.config/nvim/?.lua;" .. package.path

local Plug = vim.fn['plug#']

vim.call('plug#begin', home .. '/.config/nvim/plugged')

Plug('nvim-tree/nvim-tree.lua')
Plug('nvim-tree/nvim-web-devicons')

Plug('romgrk/barbar.nvim')

Plug('nvim-lualine/lualine.nvim')

Plug('nvim-treesitter/nvim-treesitter', { ['do'] = ':TSUpdate' })

Plug('neovim/nvim-lspconfig')

vim.call('plug#end')

require("common")
require("theme").apply()
require("nvimtree")
require("barbar-config")
require("lua_line")
require("treesitter")
require("lsp")

