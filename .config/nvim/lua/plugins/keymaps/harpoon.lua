local harpoon = require("harpoon")
local set = vim.keymap.set

set("n", "<M-h><M-m>", function()
	harpoon:list():add()
end)
set("n", "<M-h><M-l>", function()
	harpoon.ui:toggle_quick_menu(harpoon:list())
end)
