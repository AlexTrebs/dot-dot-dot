local dap = require("dap")
local ui = require("dapui")
local set = vim.keymap.set

-- Keybindings
set("n", "<space>b", dap.toggle_breakpoint)
set("n", "<space>gb", dap.run_to_cursor)
set("n", "<space>?", function()
	ui.eval(nil, { enter = true })
end)
set("n", "<F1>", dap.continue)
set("n", "<F2>", dap.step_into)
set("n", "<F3>", dap.step_over)
set("n", "<F4>", dap.step_out)
set("n", "<F5>", dap.step_back)
set("n", "<F13>", dap.restart)
