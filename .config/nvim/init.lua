vim.g.mapleader = " "
local home = os.getenv("HOME")
package.path = home .. "/.config/nvim/lua/?.lua;" .. home .. "/.config/nvim/lua/?/init.lua;" .. package.path

-- Plugins (using vim-plug)
require("plugins")

require("common")
require("theme").apply()
require("plugins.keymaps")
