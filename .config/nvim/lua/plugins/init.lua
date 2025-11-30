local Plug = vim.fn["plug#"]

local home = os.getenv("HOME")
vim.call("plug#begin", home .. "/.config/nvim/plugged")

-- ========== CORE ==========
Plug("nvim-lua/plenary.nvim")

-- ========== LSP ==========
Plug("neovim/nvim-lspconfig")
Plug("williamboman/mason.nvim")
Plug("williamboman/mason-lspconfig.nvim")
Plug("WhoIsSethDaniel/mason-tool-installer.nvim")
Plug("b0o/SchemaStore.nvim")
Plug("folke/neodev.nvim")

-- ========== CMP ==========
Plug("hrsh7th/nvim-cmp")
Plug("hrsh7th/cmp-nvim-lsp")
Plug("hrsh7th/cmp-buffer")
Plug("hrsh7th/cmp-path")
Plug("saadparwaiz1/cmp_luasnip")
Plug("L3MON4D3/LuaSnip")
Plug("onsails/lspkind.nvim")

-- ========== TREESITTER ==========
Plug("nvim-treesitter/nvim-treesitter", { ["do"] = ":TSUpdate" })

-- ========== UI ==========
Plug("romgrk/barbar.nvim")
Plug("nvim-lualine/lualine.nvim")
Plug("j-hui/fidget.nvim")
Plug("nvim-tree/nvim-tree.lua")
Plug("nvim-tree/nvim-web-devicons")

-- ========== TELESCOPE ==========
Plug("nvim-telescope/telescope.nvim")
Plug("nvim-telescope/telescope-fzf-native.nvim", { ["do"] = "make" })
Plug("nvim-telescope/telescope-ui-select.nvim")
Plug("nvim-telescope/telescope-smart-history.nvim")
Plug("kkharji/sqlite.lua")

-- ========== DAP ==========
Plug("mfussenegger/nvim-dap")
Plug("rcarriga/nvim-dap-ui")
Plug("leoluz/nvim-dap-go")
Plug("theHamsta/nvim-dap-virtual-text")
Plug("nvim-neotest/nvim-nio")

-- ========== FILES / NAVIGATION ==========
Plug("ThePrimeagen/harpoon", { branch = "harpoon2" })

-- ========== FORMATTING ==========
Plug("stevearc/conform.nvim")

-- ========== DATABASE ==========
Plug("tpope/vim-dadbod")
Plug("kristijanhusak/vim-dadbod-ui")
Plug("kristijanhusak/vim-dadbod-completion")

-- ========== MISC ==========
Plug("tjdevries/express_line.nvim")
Plug("iamcco/markdown-preview.nvim", { ["do"] = "cd app && npm install" })

-- ========== AI ==========
Plug("folke/snacks.nvim")
Plug("coder/claudecode.nvim")

vim.call("plug#end")

-- After plugin load → load configs
require("plugins.nvimtree")
require("plugins.barbar-config")
require("plugins.lua_line")
require("plugins.treesitter")
require("plugins.lsp")
require("plugins.cmp")
require("plugins.treesitter")
require("plugins.ui")
require("plugins.telescope")
require("plugins.dap")
require("plugins.formatter")
require("plugins.database")
