-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- Insert today's date in command-line mode (e.g. :e path/to/<C-t>.md)
vim.keymap.set("c", "<C-t>", function()
  return os.date("%Y-%m-%d")
end, { expr = true, desc = "Insert today's date" })

-- jj to escape insert mode
vim.keymap.set("i", "jj", "<Esc>", { desc = "Escape insert mode" })

-- Copy diagnostic message to clipboard
vim.keymap.set("n", "<leader>yc", function()
  local diag = vim.diagnostic.get(0, { lnum = vim.api.nvim_win_get_cursor(0)[1] - 1 })
  if #diag > 0 then
    vim.fn.setreg("+", diag[1].message)
    vim.notify("Copied: " .. diag[1].message, vim.log.levels.INFO)
  end
end, { desc = "Copy diagnostic message" })
