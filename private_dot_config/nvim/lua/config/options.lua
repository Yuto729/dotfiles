-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

-- TrueColorを使用
vim.opt.termguicolors = true

-- winbar にファイルパス（相対パス）+ 編集状態（%m → [+] / [-]）を表示
vim.opt.winbar = "%f%m"
local function set_winbar_hl()
  vim.api.nvim_set_hl(0, "WinBar", { fg = "#d4d4d4", bold = true })
  vim.api.nvim_set_hl(0, "WinBarNC", { fg = "#909090" })
end
vim.api.nvim_create_autocmd("ColorScheme", { callback = set_winbar_hl })
-- 初回読み込み時にも適用
set_winbar_hl()


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
