local cmp = require("cmp")
local luasnip = require("luasnip")

cmp.setup({
  snippet = {
    expand = function(args)
      luasnip.lsp_expand(args.body)
    end,
  },

  completion = {
    completeopt = "menu,menuone,noinsert",
    autocomplete = {
      require("cmp.types").cmp.TriggerEvent.TextChanged,
    },
  },

  performance = {
    max_view_entries = 50,
    debounce = 60,
    throttle = 30,
    fetching_timeout = 500,
  },

  sorting = {
    comparators = {
      cmp.config.compare.offset,
      cmp.config.compare.exact,
      cmp.config.compare.score,
      cmp.config.compare.recently_used,
      cmp.config.compare.locality,
      cmp.config.compare.kind,
      cmp.config.compare.sort_text,
      cmp.config.compare.length,
      cmp.config.compare.order,
    },
  },

  sources = {
    {
      name = "nvim_lsp",
      priority = 1000,
      -- Trigger on these characters for JS/TS
      trigger_characters = { ".", ":", "<", '"', "'", "/" },
    },
    {
      name = "buffer",
      priority = 500,
      option = {
        -- Get completions from all visible buffers
        get_bufnrs = function()
          local bufs = {}
          for _, win in ipairs(vim.api.nvim_list_wins()) do
            bufs[vim.api.nvim_win_get_buf(win)] = true
          end
          return vim.tbl_keys(bufs)
        end,
        -- Search for keywords (identifiers like variable/function names)
        keyword_pattern = [[\k\+]],
      },
    },
    { name = "path", priority = 250 },
    { name = "luasnip", priority = 750 },
  },

  mapping = cmp.mapping.preset.insert({
    ["<Tab>"] = cmp.mapping.select_next_item(),
    ["<S-Tab>"] = cmp.mapping.select_prev_item(),
    ["<CR>"] = cmp.mapping.confirm({
      behavior = cmp.ConfirmBehavior.Replace,
      select = true,
    }),
    ["<C-Space>"] = cmp.mapping.complete(),
  }),

  formatting = {
    format = require("lspkind").cmp_format({
      mode = "symbol_text",
      maxwidth = 50,
      menu = {
        nvim_lsp = "[LSP]",
        buffer = "[BUF]",
        path = "[PATH]",
      },
    }),
  },

  experimental = { ghost_text = true },
})

