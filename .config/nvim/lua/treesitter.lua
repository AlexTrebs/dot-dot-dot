require'nvim-treesitter.configs'.setup {
  highlight = { enable = true },
	ensure_installed = {
		"lua",
		"vim",
		"vimdoc",
		"bash",
		"python",
		"javascript",
		"html",
		"css",
		"json",
		"yaml",
		"markdown",
	},

  sync_install = false,
  auto_install = true,
}

