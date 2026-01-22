return {
  -- LazyVimのデフォルトカラースキームを無効化
  { "folke/tokyonight.nvim", enabled = false },
  { "catppuccin/nvim", enabled = false },

  -- ターミナルカラーを使用するための設定
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "default",
    },
  },
}
