-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

-- TrueColorを使用
vim.opt.termguicolors = true

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
