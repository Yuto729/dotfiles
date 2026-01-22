return {
  "sindrets/diffview.nvim",
  config = function()
    require("diffview").setup()
  end,
  lazy = false,
  keys = {
    { "<leader>do", "<cmd>DiffviewOpen<CR>", desc = "Diffview: 現在の変更を表示" },
    { "<leader>dh", "<cmd>DiffviewOpen HEAD~1<CR>", desc = "Diffview: 1つ前とのdiff" },
    { "<leader>dm", "<cmd>DiffviewOpen main..HEAD<CR>", desc = "Diffview: mainとの差分" },
    { "<leader>dd", "<cmd>DiffviewOpen develop..HEAD<CR>", desc = "Diffview: developとの差分" },
    { "<leader>df", "<cmd>DiffviewFileHistory %<CR>", desc = "Diffview: ファイルの履歴" },
    { "<leader>dF", "<cmd>DiffviewFileHistory<CR>", desc = "Diffview: 全ファイルの履歴" },
    { "<leader>dc", "<cmd>DiffviewClose<CR>", desc = "Diffview: 閉じる" },
  },
}
