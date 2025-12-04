local builtin = require("telescope.builtin")
local set = vim.keymap.set

-- LSP keybindings
set("n", "gd", vim.lsp.buf.definition)
set("n", "gr", vim.lsp.buf.references)
set("n", "gD", vim.lsp.buf.declaration)
set("n", "gT", vim.lsp.buf.type_definition)
set("n", "K", vim.lsp.buf.hover)
set("n", "<space>cr", vim.lsp.buf.rename)
set("n", "<space>ca", vim.lsp.buf.code_action)
set("n", "<space>wd", vim.lsp.buf.document_symbol or builtin.lsp_document_symbols)
set("n", "<leader>e", vim.diagnostic.open_float)
set("n", "<space>ww", function()
	builtin.diagnostics({ root_dir = true })
end)
set("n", "<space>f", function()
	require("conform").format()
end)
