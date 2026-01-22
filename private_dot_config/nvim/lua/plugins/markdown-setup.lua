return {
  -- conform.nvimのMarkdownフォーマッターを有効化（prettier使用のみ）
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        markdown = { "prettier" },
        ["markdown.mdx"] = { "prettier" },
      },
      formatters = {
        prettier = {
          prepend_args = { "--prose-wrap", "preserve" }, -- 日本語の改行を保持
        },
      },
    },
  },
  -- lintは完全に無効化
  {
    "nvimtools/none-ls.nvim",
    optional = true,
    opts = function(_, opts)
      opts.sources = vim.tbl_filter(function(source)
        return source.name ~= "markdownlint_cli2"
          and source.name ~= "markdownlint"
      end, opts.sources or {})
      return opts
    end,
  },
  -- Masonでprettierのみインストール
  {
    "mason-org/mason.nvim",
    opts = {
      ensure_installed = {
        "prettier",
      },
    },
  },
}