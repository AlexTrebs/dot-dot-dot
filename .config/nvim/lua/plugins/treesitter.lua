require("nvim-treesitter.configs").setup({
	-- List of parsers to install
	ensure_installed = {
		"c",
		"javascript",
		"typescript",
		"python",
		"svelte",
		"yaml",
		"json",
		"rust",
		"go",
		"gomod",
		"helm",
		"java",
		"bash",
		"dockerfile",
		"lua",
		"vim",
		"vimdoc",
		"query",
		"markdown",
		"markdown_inline",
		"html",
		"css",
	},

	-- Install parsers synchronously
	sync_install = false,

	-- Automatically install missing parsers when entering buffer
	auto_install = true,

	highlight = {
		enable = true,
		additional_vim_regex_highlighting = false,
	},

	indent = {
		enable = true,
	},

	playground = {
		enable = true,
		disable = {},
		updatetime = 25,
		persist_queries = false,
	},
})
