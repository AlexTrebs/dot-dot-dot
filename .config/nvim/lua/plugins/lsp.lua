require("neodev").setup()

local cmp_capabilities = nil
if pcall(require, "cmp_nvim_lsp") then
	cmp_capabilities = require("cmp_nvim_lsp").default_capabilities()
end

local on_attach = function(client, bufnr)
	local opts = { buffer = bufnr, noremap = true, silent = true }

	vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
	vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
	vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
	vim.keymap.set("n", "gT", vim.lsp.buf.type_definition, opts)
	vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
	vim.keymap.set("n", "<leader>cr", vim.lsp.buf.rename, opts)
	vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)

	-- TypeScript specific: organize imports and add missing imports
	if client.name == "ts_ls" then
		vim.keymap.set("n", "<leader>co", function()
			vim.lsp.buf.code_action({
				apply = true,
				context = {
					only = { "source.organizeImports" },
					diagnostics = {},
				},
			})
		end, opts)

		-- Add missing imports keybinding
		vim.keymap.set("n", "<leader>ci", function()
			vim.lsp.buf.code_action({
				apply = true,
				context = {
					only = { "source.addMissingImports.ts" },
					diagnostics = {},
				},
			})
		end, opts)
	end

	if client.name == "rust_analyzer" then
		client.server_capabilities.semanticTokensProvider = nil
	end

	if client.name == "lua_ls" then
		client.server_capabilities.semanticTokensProvider = nil
	end
end

-- LSP servers
local servers = {
	bashls = true,
	gopls = {
		settings = { gopls = { hints = { assignVariableTypes = true } } },
	},
	lua_ls = true,
	rust_analyzer = true,
	svelte = true,
	templ = true,
	cssls = true,
	ts_ls = {
		settings = {
			typescript = {
				inlayHints = {
					includeInlayParameterNameHints = "all",
					includeInlayParameterNameHintsWhenArgumentMatchesName = false,
					includeInlayFunctionParameterTypeHints = true,
					includeInlayVariableTypeHints = true,
					includeInlayPropertyDeclarationTypeHints = true,
					includeInlayFunctionLikeReturnTypeHints = true,
					includeInlayEnumMemberValueHints = true,
				},
			},
			javascript = {
				inlayHints = {
					includeInlayParameterNameHints = "all",
					includeInlayParameterNameHintsWhenArgumentMatchesName = false,
					includeInlayFunctionParameterTypeHints = true,
					includeInlayVariableTypeHints = true,
					includeInlayPropertyDeclarationTypeHints = true,
					includeInlayFunctionLikeReturnTypeHints = true,
					includeInlayEnumMemberValueHints = true,
				},
			},
		},
	},
	eslint = true,
	jsonls = true,
	yamlls = true,
	pyright = true,
	ruby_lsp = {
		settings = {
			rubyLsp = {
				diagnostics = true,
				formatter = "rubocop",
				linters = { "rubocop" },
			},
		},
	},
}

-- Install servers via Mason
local servers_to_install = vim.tbl_filter(function(key)
	return servers[key] ~= false
end, vim.tbl_keys(servers))

require("mason").setup()
require("mason-tool-installer").setup({ ensure_installed = servers_to_install })

-- Setup mason-lspconfig with handlers to automatically configure servers
require("mason-lspconfig").setup({
	ensure_installed = servers_to_install,
	handlers = {
		-- Default handler for all servers
		function(server_name)
			local config = servers[server_name]
			if config == false then
				return
			end
			if config == true then
				config = {}
			end
			config = vim.tbl_deep_extend("force", {
				on_attach = on_attach,
				capabilities = cmp_capabilities or {},
			}, config)

			require("lspconfig")[server_name].setup(config)
		end,
	},
})
