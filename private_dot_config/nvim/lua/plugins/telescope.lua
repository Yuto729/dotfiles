return {
  "nvim-telescope/telescope.nvim",
  opts = function(_, opts)
    opts.defaults = opts.defaults or {}
    opts.defaults.file_ignore_patterns = { "%.git/" }
    opts.pickers = opts.pickers or {}
    opts.pickers.find_files = {
      hidden = true,
      no_ignore = true,
    }
    opts.pickers.live_grep = {
      additional_args = { "--hidden", "--no-ignore" },
    }
    return opts
  end,
}
