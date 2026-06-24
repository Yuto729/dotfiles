return {
  "nvim-lualine/lualine.nvim",
  opts = function(_, opts)
    local icons = LazyVim.config.icons

    -- ファイルパス(root_dir + pretty_path)は winbar に出しているので statusline からは省く。
    -- 診断アイコンとファイルタイプアイコンだけ残す。
    opts.sections.lualine_c = {
      {
        "diagnostics",
        symbols = {
          error = icons.diagnostics.Error,
          warn = icons.diagnostics.Warn,
          info = icons.diagnostics.Info,
          hint = icons.diagnostics.Hint,
        },
      },
      { "filetype", icon_only = true, separator = "", padding = { left = 1, right = 0 } },
    }

    -- location(行:列) も progress(スクロール位置%) も使わないので空にする
    opts.sections.lualine_y = {}

    -- 時計は削除（tmux / OS バーにあるため）。
    -- nil にすると lualine が既定の location で埋め直すので、空テーブルで明示的に空にする。
    opts.sections.lualine_z = {}
  end,
}
