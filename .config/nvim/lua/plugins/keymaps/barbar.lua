local set = vim.keymap.set

-- Buffer navigation
set("n", "<C-Tab>", "<Cmd>BufferNext<CR>", { desc = "Next buffer" })
set("n", "<C-S-Tab>", "<Cmd>BufferPrevious<CR>", { desc = "Previous buffer" })

-- Move buffers
set("n", "<leader>>", "<Cmd>BufferMoveNext<CR>", { desc = "Move buffer right" })
set("n", "<leader><", "<Cmd>BufferMovePrevious<CR>", { desc = "Move buffer left" })

-- Close buffers
set("n", "<leader>bc", "<Cmd>BufferClose<CR>", { desc = "Close current buffer" })
set("n", "<leader>bo", "<Cmd>BufferCloseAllButCurrent<CR>", { desc = "Close other buffers" })

-- Go to buffer by number (1-9)
for i = 1, 9 do
	set("n", "<leader>" .. i, "<Cmd>BufferGoto " .. i .. "<CR>", { desc = "Go to buffer " .. i })
end

-- Pin/unpin buffer
set("n", "<leader>bp", "<Cmd>BufferPin<CR>", { desc = "Pin/unpin buffer" })
