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
	ts_ls = true,
	jsonls = true,
	yamlls = true,
	pyright = true,
}

-- Install servers via Mason
local servers_to_install = vim.tbl_filter(function(key)
	return servers[key] ~= false
end, vim.tbl_keys(servers))

require("mason").setup()
require("mason-lspconfig").setup({ ensure_installed = servers_to_install })
require("mason-tool-installer").setup({ ensure_installed = servers_to_install })

-- Register LSP servers
local lsp = vim.lsp
for name, config in pairs(servers) do
	if config == true then
		config = {}
	end
	config = vim.tbl_deep_extend("force", { on_attach = on_attach, capabilities = cmp_capabilities or {} }, config)
	lsp.config[name] = config
	lsp.enable(name)
end
