local set = vim.keymap.set

-- Open terminal in a 5-line bottom split
set("n", "<leader>t", function()
	vim.cmd("botright 5split")
	vim.cmd("terminal")
	vim.cmd("startinsert")
end, { noremap = true, silent = true })

-- Exit terminal insert mode
set("t", "<Esc>", "<C-\\><C-n>", { noremap = true, silent = true })
