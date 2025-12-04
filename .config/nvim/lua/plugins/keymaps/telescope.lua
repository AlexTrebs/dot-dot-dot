local builtin = require("telescope.builtin")
local set = vim.keymap.set

set("n", "<space>fd", builtin.find_files)
set("n", "<space>ft", function()
	return builtin.git_files({ cwd = vim.fn.expand("%:h") })
end)
set("n", "<space>fh", builtin.help_tags)
set("n", "<space>fg", require("plugins.multi-ripgrep"))
set("n", "<space>fb", builtin.buffers)
set("n", "<space>/", builtin.current_buffer_fuzzy_find)
set("n", "<space>gw", builtin.grep_string)
