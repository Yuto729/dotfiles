-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)

-- Markdownでのスペルチェックを無効化（日本語対応）
-- lazyvim_wrap_spell グループはwrapも設定するため丸ごと削除せず、spellだけ無効化する
-- 参考: https://clameyes.com/posts/lazyvim-underline-red-wave-remove-japanese
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "markdown", "gitcommit" },
  callback = function()
    vim.opt_local.spell = false
    vim.opt_local.wrap = true
  end,
})
