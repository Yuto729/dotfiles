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
      "markdown",
      "markdown_inline",
    },
    highlight = {
      enable = true,
    },
  },
}