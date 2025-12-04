-- Global options
vim.g.mouse = "a"
vim.g.mapleader = " "
vim.opt.encoding = "utf-8"
vim.opt.swapfile = false
vim.opt.scrolloff = 7
vim.opt.tabstop = 2
vim.opt.softtabstop = 2
vim.opt.shiftwidth = 2
vim.o.expandtab = true
vim.g.rust_recommended_style = 0
vim.opt.autoindent = true
vim.opt.fileformat = "unix"
vim.wo.number = true

-- Terminal buffer settings
vim.api.nvim_create_autocmd("TermOpen", {
	callback = function(args)
		vim.cmd("setlocal nobuflisted")
		vim.cmd("startinsert")
		vim.wo.number = false
		vim.wo.relativenumber = false
	end,
})

vim.api.nvim_create_autocmd({ "UIEnter", "ColorScheme" }, {
	callback = function()
		local normal = vim.api.nvim_get_hl(0, { name = "Normal" })
		if not normal.bg then
			return
		end
		io.write(string.format("\027]11;#%06x\027\\", normal.bg))
	end,
})

vim.api.nvim_create_autocmd("UILeave", {
	callback = function()
		io.write("\027]111\027\\")
	end,
})
