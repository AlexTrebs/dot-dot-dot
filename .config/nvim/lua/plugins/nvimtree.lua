require("nvim-tree").setup({
	view = { side = "left", width = 25 },
	renderer = {
		highlight_opened_files = "all",
	},
	update_focused_file = { enable = true },
	git = { enable = true },
})
