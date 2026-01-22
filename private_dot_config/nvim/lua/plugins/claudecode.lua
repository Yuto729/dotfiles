return {
  {
    "coder/claudecode.nvim",
    dependencies = { "folke/snacks.nvim" },
    opts = {
      terminal = {
        split_width_percentage = 0.35,
        split_side = "right",
        -- snacks or autoにすると, edgyのレイアウト設定で上書きされてwidthが制御できないので, nativeにする.
        provider = "native",
      },
    },
    keys = {
      { "<leader>a", "", desc = "+ai", mode = { "n", "v" } },
      { "<leader>ac", "<cmd>ClaudeCode<cr>", desc = "Toggle Claude" },
      { "<leader>af", "<cmd>ClaudeCodeFocus<cr>", desc = "Focus Claude" },
      { "<leader>ar", "<cmd>ClaudeCode --resume<cr>", desc = "Resume Claude" },
      { "<leader>aC", "<cmd>ClaudeCode --continue<cr>", desc = "Continue Claude" },
      { "<leader>an", "<cmd>ClaudeCode --new<cr>", desc = "New Claude conversation" },
      { "<leader>ab", "<cmd>ClaudeCodeAdd %<cr>", desc = "Add current buffer" },
      { "<leader>as", "<cmd>ClaudeCodeSend<cr>", mode = "v", desc = "Send to Claude" },
      {
        "<leader>as",
        "<cmd>ClaudeCodeTreeAdd<cr>",
        desc = "Add file",
        ft = { "NvimTree", "neo-tree", "oil" },
      },
      -- Diff management
      { "<leader>aa", "<cmd>ClaudeCodeDiffAccept<cr>", desc = "Accept diff" },
      { "<leader>ad", "<cmd>ClaudeCodeDiffDeny<cr>", desc = "Deny diff" },
      -- Window resize (same as terminal)
      { "<C-Left>", "<cmd>vertical resize -2<cr>", desc = "Decrease width" },
      { "<C-Right>", "<cmd>vertical resize +2<cr>", desc = "Increase width" },
      { "<C-Up>", "<cmd>resize +2<cr>", desc = "Increase height" },
      { "<C-Down>", "<cmd>resize -2<cr>", desc = "Decrease height" },
    },
  },
}
