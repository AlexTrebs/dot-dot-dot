local dap = require("dap")
local dapui = require("dapui")
local dap_go = require("dap-go")

-- Setup DAP UI
dapui.setup()
dap_go.setup()

-------------------
-- DAP Adapters --
-------------------

-- Go (delve)
dap.adapters.go = {
	type = "server",
	port = "${port}",
	executable = {
		command = "dlv",
		args = { "dap", "-l", "127.0.0.1:${port}" },
	},
}

-- Python (debugpy)
dap.adapters.python = {
	type = "executable",
	command = "python",
	args = { "-m", "debugpy.adapter" },
}

-- JS/TS/Svelte/React
dap.adapters.node2 = {
	type = "executable",
	command = "node",
	args = { os.getenv("HOME") .. "/.local/share/nvim/mason/packages/js-debug-adapter/js-debug/src/dapDebugServer.js" },
}

-- Rust/C (codelldb)
dap.adapters.codelldb = {
	type = "server",
	port = "${port}",
	executable = {
		command = "codelldb",
		args = { "--port", "${port}" },
	},
}

-- Bash
dap.adapters.bashdb = {
	type = "executable",
	command = "bash-debug-adapter",
}

-- Java
dap.adapters.java = {
	type = "server",
	host = "127.0.0.1",
	port = 5005,
}

-- Lua (attach to Neovim itself)
dap.adapters.nlua = function(callback)
	callback({ type = "nlua", host = "127.0.0.1", port = 8086 })
end

---------------------------
-- DAP Configurations --
---------------------------

-- Go
dap.configurations.go = {
	{
		type = "go",
		name = "Debug",
		request = "launch",
		program = "${file}",
	},
}

-- Python
dap.configurations.python = {
	{
		type = "python",
		request = "launch",
		name = "Launch file",
		program = "${file}",
		pythonPath = "python3",
	},
}

-- JS/TS/Svelte/React
dap.configurations.javascript = {
	{
		type = "node2",
		request = "launch",
		name = "Launch JS/TS file",
		program = "${file}",
		cwd = vim.fn.getcwd(),
		sourceMaps = true,
		protocol = "inspector",
	},
}
dap.configurations.typescript = dap.configurations.javascript
dap.configurations.svelte = dap.configurations.javascript
dap.configurations.javascriptreact = dap.configurations.javascript
dap.configurations.typescriptreact = dap.configurations.javascript

-- Rust/C
dap.configurations.rust = {
	{
		type = "codelldb",
		request = "launch",
		name = "Launch Rust",
		program = function()
			return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/target/debug/", "file")
		end,
		cwd = "${workspaceFolder}",
		stopOnEntry = false,
	},
}
dap.configurations.c = dap.configurations.rust

-- Bash
dap.configurations.bash = {
	{
		type = "bashdb",
		request = "launch",
		name = "Launch Bash",
		program = "${file}",
	},
}

-- Java
dap.configurations.java = {
	{
		type = "java",
		request = "attach",
		name = "Attach to Java",
		hostName = "127.0.0.1",
		port = 5005,
	},
}

-- Lua (Neovim)
dap.configurations.lua = {
	{
		type = "nlua",
		request = "attach",
		name = "Attach to Neovim",
	},
}
