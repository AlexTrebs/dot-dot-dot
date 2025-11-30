-- Global options
vim.g.mouse = "a"
vim.g.mapleader = " "
vim.opt.encoding = "utf-8"
vim.opt.swapfile = false
vim.opt.scrolloff = 7
vim.opt.tabstop = 2
vim.opt.softtabstop = 2
vim.opt.shiftwidth = 2
vim.opt.autoindent = true
vim.opt.fileformat = "unix"
vim.wo.number = true

-- Terminal buffer settings
vim.api.nvim_create_autocmd("TermOpen", {
	callback = function(args)
		vim.wo.number = false
		vim.wo.relativenumber = false
	end,
})
