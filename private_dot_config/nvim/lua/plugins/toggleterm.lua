return {
  {
    "akinsho/toggleterm.nvim",
    opts = {
      size = 20,
      open_mapping = [[<c-\>]],
      direction = "horizontal",
      shading_factor = 2,
      float_opts = {
        border = "curved",
      },
    },
    keys = {
      { "<leader>tt", "<cmd>ToggleTerm<cr>", desc = "Toggle terminal" },
      { "<leader>t1", "<cmd>1ToggleTerm<cr>", desc = "Terminal 1" },
      { "<leader>t2", "<cmd>2ToggleTerm<cr>", desc = "Terminal 2" },
      { "<leader>t3", "<cmd>3ToggleTerm<cr>", desc = "Terminal 3" },
      { "<leader>t+", function()
        local terms = require("toggleterm.terminal").get_all()
        local next_id = #terms + 1
        vim.cmd(next_id .. "ToggleTerm")
      end, desc = "New terminal" },
    },
  },
}