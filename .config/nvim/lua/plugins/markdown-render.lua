-- Only load if the plugin is available
local ok, render_markdown = pcall(require, "render-markdown")
if not ok then
	return
end

render_markdown.setup({
	-- Enable rendering by default
	enabled = true,

	-- Maximum file size to render (in KB), prevents lag on huge files
	max_file_size = 1.5,

	-- Render markdown in the background for better performance
	render_modes = { "n", "c", "i" }, -- normal, command, insert modes

	-- Headings configuration
	heading = {
		-- Enable heading rendering
		enabled = true,

		-- Characters to use for heading signs
		sign = true,

		-- Icons for each heading level
		icons = { "󰲡 ", "󰲣 ", "󰲥 ", "󰲧 ", "󰲩 ", "󰲫 " },

		-- Heading sizes/styles (uses highlight groups)
		backgrounds = { "DiffAdd", "DiffChange", "DiffDelete" },
		foregrounds = {
			"markdownH1",
			"markdownH2",
			"markdownH3",
			"markdownH4",
			"markdownH5",
			"markdownH6",
		},
	},

	-- Code blocks
	code = {
		-- Enable code block rendering
		enabled = true,

		-- Character to use for code block borders
		sign = true,

		-- Style: 'full' (background), 'normal', 'language', 'none'
		style = "full",

		-- Where to show the language name
		position = "left",

		-- Highlight for code blocks
		highlight = "ColorColumn",
	},

	-- Inline code rendering
	inline_code = {
		enabled = true,
		highlight = "ColorColumn",
	},

	-- Checkbox rendering
	checkbox = {
		enabled = true,
		unchecked = { icon = "󰄱 " },
		checked = { icon = "󰱒 " },
	},

	-- Bullet points
	bullet = {
		enabled = true,
		icons = { "●", "○", "◆", "◇" },
	},

	-- Quotes
	quote = {
		enabled = true,
		icon = "▎",
		highlight = "Comment",
	},

	-- Tables
	table = {
		enabled = true,
		style = "full",
	},

	-- Links - conceal URLs, show just the text
	link = {
		enabled = true,
		hyperlink = "󰌷 ",
		image = "󰥶 ",
	},

	-- Horizontal rules
	dash = {
		enabled = true,
		icon = "─",
		width = "full",
	},

	-- Don't render in these filetypes
	excluded_filetypes = {},
})

-- Keybindings for toggling markdown rendering
vim.keymap.set("n", "<leader>md", function()
	require("render-markdown").toggle()
end, { noremap = true, silent = true, desc = "Toggle markdown rendering" })
