local function on_attach(bufnr)
	local api = require("nvim-tree.api")

	local function opts(desc)
		return { desc = "nvim-tree: " .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
	end

	-- Default mappings
	api.config.mappings.default_on_attach(bufnr)

	-- Custom handler for opening files
	local function open_file()
		local node = api.tree.get_node_under_cursor()
		if not node then
			return
		end

		local path = node.absolute_path
		local image_extensions = { "png", "jpg", "jpeg", "gif", "bmp", "webp", "svg", "ico" }

		-- Check if file is an image
		local extension = path:match("^.+%.(.+)$")
		if extension then
			extension = extension:lower()
			for _, ext in ipairs(image_extensions) do
				if extension == ext then
					-- Open image with external viewer
					vim.fn.jobstart({ "xdg-open", path }, { detach = true })
					return
				end
			end
		end

		-- Default behavior for non-images
		api.node.open.edit()
	end

	-- Override the default open mapping
	vim.keymap.set("n", "<CR>", open_file, opts("Open"))
	vim.keymap.set("n", "o", open_file, opts("Open"))
end

require("nvim-tree").setup({
	view = { side = "left", width = 25 },
	renderer = {
		highlight_opened_files = "none", -- Disable to avoid conflicts with git highlighting
		highlight_git = "name", -- Highlight file names with git status
		highlight_modified = "name", -- Highlight modified files
		highlight_diagnostics = "name", -- Highlight files with LSP diagnostics
		icons = {
			show = {
				git = false, -- Disable git icons
				folder = false, -- Disable folder icons
				file = false, -- Disable file icons
				diagnostics = false, -- Disable diagnostic icons
			},
			glyphs = {
				git = {
					unstaged = "",
					staged = "",
					unmerged = "",
					renamed = "",
					untracked = "",
					deleted = "",
					ignored = "",
				},
			},
		},
	},
	update_focused_file = { enable = true },
	git = {
		enable = true,
		ignore = false,
		show_on_dirs = true, -- Show git status on parent directories
		show_on_open_dirs = true, -- Show git status on open directories
	},
	modified = {
		enable = true,
		show_on_dirs = true,
	},
	diagnostics = {
		enable = true,
		show_on_dirs = true, -- Show diagnostics on parent directories
		show_on_open_dirs = true,
		severity = {
			min = vim.diagnostic.severity.HINT,
			max = vim.diagnostic.severity.ERROR,
		},
	},
	on_attach = on_attach,
})
