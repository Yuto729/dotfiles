return {
  -- LazyVimのデフォルトカラースキームを無効化
  { "folke/tokyonight.nvim", enabled = false },
  { "catppuccin/nvim", enabled = false },

  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "vscode",
    },
  },
}
