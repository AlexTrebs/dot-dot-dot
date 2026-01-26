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
		"ruby",
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

-- Setup nvim-ts-autotag separately (not through treesitter config)
local ok, autotag = pcall(require, "nvim-ts-autotag")
if ok then
	autotag.setup({
	opts = {
		enable_close = true, -- Auto close tags
		enable_rename = true, -- Auto rename pairs of tags
		enable_close_on_slash = true, -- Auto close on trailing </
	},
	per_filetype = {
		["html"] = {
			enable_close = true,
		},
		["javascript"] = {
			enable_close = true,
		},
		["typescript"] = {
			enable_close = true,
		},
		["javascriptreact"] = {
			enable_close = true,
		},
		["typescriptreact"] = {
			enable_close = true,
		},
		["svelte"] = {
			enable_close = true,
		},
	},
	})
end
