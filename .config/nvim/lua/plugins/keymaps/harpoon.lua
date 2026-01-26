local harpoon = require("harpoon")
local set = vim.keymap.set

-- Setup Harpoon 2
harpoon:setup()

-- ADD file to Harpoon marks
set("n", "<leader>a", function()
    harpoon:list():add()
    print("✓ Added to Harpoon!")
end, { desc = "Harpoon: Add file" })

-- TOGGLE Harpoon quick menu
set("n", "<leader>m", function()
    harpoon.ui:toggle_quick_menu(harpoon:list())
end, { desc = "Harpoon: Toggle menu" })

-- Navigate between harpoon marks (using different keys to avoid conflicts)
set("n", "<leader>j", function() harpoon:list():select(1) end, { desc = "Harpoon: Jump to file 1" })
set("n", "<leader>k", function() harpoon:list():select(2) end, { desc = "Harpoon: Jump to file 2" })
set("n", "<leader>l", function() harpoon:list():select(3) end, { desc = "Harpoon: Jump to file 3" })
set("n", "<leader>;", function() harpoon:list():select(4) end, { desc = "Harpoon: Jump to file 4" })

-- Cycle through marks
set("n", "<leader>n", function() harpoon:list():next() end, { desc = "Harpoon: Next file" })
set("n", "<leader>p", function() harpoon:list():prev() end, { desc = "Harpoon: Previous file" })
