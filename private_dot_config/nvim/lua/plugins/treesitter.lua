return {
  "nvim-treesitter/nvim-treesitter",
  opts = {
    ensure_installed = {
      "bash",
      "lua",
      "python",
      "typescript",
      "tsx",
      "javascript",
      "json",
      "yaml",
      -- "markdown", -- Markdownのパーサーを無効化
      -- "markdown_inline",
    },
    highlight = {
      enable = true,
      disable = { "markdown" }, -- Markdownのハイライトを無効化
    },
  },
}