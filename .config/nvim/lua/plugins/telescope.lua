local telescope = require("telescope")

telescope.setup({
  defaults = {
    history = {
      path = vim.fn.stdpath("data") .. "/telescope_history.sqlite3",
    },
  },
})

require("telescope").load_extension("fzf")
require("telescope").load_extension("ui-select")

