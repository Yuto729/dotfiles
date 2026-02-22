return {
  "folke/snacks.nvim",
  opts = {
    indent = { enabled = true },
  },
  keys = {
    { "<c-/>", function() Snacks.terminal() end, mode = { "n", "t" }, desc = "Toggle Terminal" },
  },
}
