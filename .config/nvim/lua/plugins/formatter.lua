local conform = require("conform")

conform.setup({
	format_on_save = true,
	formatters_by_ft = {
		lua = { "stylua" },
		go = { "gofmt" },
		python = { "black" },
		javascript = { "prettier" },
		typescript = { "prettier" },
		javascriptreact = { "prettier" },
		typescriptreact = { "prettier" },
		svelte = { "prettier" },
		css = { "prettier" },
		scss = { "prettier" },
		json = { "prettier" },
		yaml = { "prettier" },
		html = { "prettier" },
		markdown = { "prettier" },
		bash = { "shfmt" },
		dockerfile = { "hadolint" },
		rust = { "rustfmt", lsp_format = "fallback" },
		java = { "google_java_format" },
	},
})

vim.api.nvim_create_autocmd("BufWritePre", {
	callback = function(args)
		conform.format({ bufnr = args.buf, lsp_fallback = true, quiet = true })
	end,
})
