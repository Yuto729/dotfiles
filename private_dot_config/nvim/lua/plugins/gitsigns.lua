return {
  {
    "lewis6991/gitsigns.nvim",
    event = "VeryLazy",
    opts = {
      on_attach = function(buffer)
        local gs = package.loaded.gitsigns
        local function map(mode, l, r, desc)
          vim.keymap.set(mode, l, r, { buffer = buffer, desc = desc })
        end
        -- Hunk操作のみ
        map("n", "]h", function() gs.nav_hunk("next") end, "Next Hunk")
        map("n", "[h", function() gs.nav_hunk("prev") end, "Prev Hunk")
        map("n", "<leader>hr", gs.reset_hunk, "Reset Hunk")
        map("n", "<leader>hs", gs.stage_hunk, "Stage Hunk")
        map("n", "<leader>hu", gs.undo_stage_hunk, "Undo Stage Hunk")
        map("n", "<leader>hp", gs.preview_hunk_inline, "Preview Hunk")
      end,
    },
  },
}