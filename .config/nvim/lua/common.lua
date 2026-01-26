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

vim.api.nvim_create_autocmd("FileType", {
	pattern = "python",
	callback = function()
		vim.opt_local.expandtab = true
		vim.opt_local.tabstop = 2
		vim.opt_local.shiftwidth = 2
		vim.opt_local.softtabstop = 2
	end,
})

vim.opt.autoread = true
vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "CursorHold", "CursorHoldI" }, {
	pattern = "*",
	command = "checktime",
})

-- Auto-fix imports after pasting in JS/TS files
local auto_import_group = vim.api.nvim_create_augroup("AutoImport", { clear = true })

-- Function to add missing imports
local function add_missing_imports()
	local bufnr = vim.api.nvim_get_current_buf()
	local filetype = vim.bo[bufnr].filetype

	-- Only run for JS/TS files
	if not vim.tbl_contains({ "javascript", "typescript", "javascriptreact", "typescriptreact" }, filetype) then
		return
	end

	-- Wait for LSP to be ready and diagnostics to update
	vim.defer_fn(function()
		local clients = vim.lsp.get_clients({ bufnr = bufnr })
		local ts_client = nil

		for _, client in ipairs(clients) do
			if client.name == "ts_ls" then
				ts_client = client
				break
			end
		end

		if not ts_client then
			return
		end

		-- Get all diagnostics
		local diagnostics = vim.diagnostic.get(bufnr)

		-- Check if there are any missing import errors
		local has_missing_imports = false
		for _, diagnostic in ipairs(diagnostics) do
			if diagnostic.code and (diagnostic.code == 2304 or diagnostic.code == 2305 or diagnostic.code == 2552) then
				has_missing_imports = true
				break
			end
		end

		if has_missing_imports then
			-- Apply add missing imports code action
			vim.lsp.buf.code_action({
				apply = true,
				context = {
					only = { "source.addMissingImports.ts" },
					diagnostics = {},
				},
			})
		end
	end, 500) -- Wait 500ms for diagnostics to populate
end

-- Trigger on TextChanged after paste (normal mode)
vim.api.nvim_create_autocmd("TextChanged", {
	group = auto_import_group,
	pattern = { "*.js", "*.jsx", "*.ts", "*.tsx" },
	callback = function()
		-- Only trigger if significant text was added (likely a paste)
		local changedtick = vim.b.changedtick or 0
		local last_changedtick = vim.b.last_auto_import_tick or 0

		if changedtick - last_changedtick > 5 then -- More than 5 changes suggests a paste
			add_missing_imports()
		end

		vim.b.last_auto_import_tick = changedtick
	end,
})

-- Keybinding to manually trigger import fixing
vim.keymap.set("n", "<leader>cI", function()
	add_missing_imports()
end, { noremap = true, silent = true, desc = "Add missing imports" })

-- Smart paste: paste and auto-add imports for JS/TS files
vim.keymap.set("n", "gp", function()
	vim.cmd("normal! p")
	add_missing_imports()
end, { noremap = true, silent = true, desc = "Paste and add missing imports" })

vim.keymap.set("n", "gP", function()
	vim.cmd("normal! P")
	add_missing_imports()
end, { noremap = true, silent = true, desc = "Paste before and add missing imports" })
