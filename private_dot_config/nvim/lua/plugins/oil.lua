return {
  "stevearc/oil.nvim",
  ---@module 'oil'
  ---@type oil.SetupOpts
  opts = {
    view_options = {
      show_hidden = true,
    },
    keymaps = {
      ["q"] = "actions.close",
    },
  },
  dependencies = { { "nvim-mini/mini.icons", opts = {} } },
  lazy = false,
  keys = {
    { "-", "<cmd>Oil<cr>", desc = "Open Oil (parent directory)" },
  },
}
