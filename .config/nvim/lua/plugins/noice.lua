require("noice").setup({
	cmdline = {
		view = "mini", -- uses top view
	},
	views = {
		cmdline = {
			position = {
				row = 0, -- Move to the very top row
				col = "100%", -- Center it horizontally (optional)
			},
		},
	},
})
