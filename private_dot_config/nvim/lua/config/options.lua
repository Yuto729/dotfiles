-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

-- TrueColorを使用
vim.opt.termguicolors = true

-- winbar にファイルパスを表示（相対パス）
vim.opt.winbar = "%f"
vim.api.nvim_create_autocmd("ColorScheme", {
  callback = function()
    vim.api.nvim_set_hl(0, "WinBar", { fg = "#888888" })
    vim.api.nvim_set_hl(0, "WinBarNC", { fg = "#555555" })
  end,
})
-- 初回読み込み時にも適用
vim.api.nvim_set_hl(0, "WinBar", { fg = "#888888" })
vim.api.nvim_set_hl(0, "WinBarNC", { fg = "#555555" })


-- 入力中は list をオフにする（trail 表示を一時的に非表示）
vim.api.nvim_create_autocmd("InsertEnter", {
  callback = function()
    vim.opt.list = false
  end,
})
vim.api.nvim_create_autocmd("InsertLeave", {
  callback = function()
    vim.opt.list = true
  end,
})
