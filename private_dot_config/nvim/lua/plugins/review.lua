-- review.nvim v1.10.1 のコメント一覧は別ファイルのコメントへ飛べない（ファイルパネルの最上位にある
-- グループしか探さず、codediff.nvim に無い select_node を呼んでいる）ので、一覧を差し替える。
-- codediff.nvim の内部APIに依存するため、両プラグインは tag で固定している。上げるときはここを確認する。
-- 本家では georgeguimaraes/review.nvim#54 が同じバグの修正を出している。入ったら差し替えは外せる。
local function list_comments()
  local hooks = require("review.hooks")
  local types = require("review.config").get().comment_types
  local all = require("review.store").get_all()
  if #all == 0 then
    vim.notify("No comments yet", vim.log.levels.INFO, { title = "review.nvim" })
    return
  end

  vim.ui.select(all, {
    prompt = "Comments:",
    format_item = function(c)
      local t = types[c.type] or {}
      local loc = c.line == 0 and c.file or string.format("%s:%s%d", c.file, c.side == "old" and "~" or "", c.line)
      return string.format("%s %s [%s] %s", t.icon or "●", loc, t.name or c.type, (c.text:gsub("\n", " ")))
    end,
  }, function(c)
    if not c then
      return
    end
    local line = math.max(c.line, 1)
    local tabpage = hooks.get_current_tabpage()
    local explorer = tabpage == vim.api.nvim_get_current_tabpage() and hooks.get_explorer(tabpage)

    -- diff を開いていないときは、普通にファイルを開いて飛ぶ
    if not explorer then
      local root = require("review.utils").git_root()
      if root then
        vim.cmd.edit(vim.fn.fnameescape(root .. "/" .. c.file))
        pcall(vim.api.nvim_win_set_cursor, 0, { line, 0 })
      end
      return
    end

    local function target_win()
      local sess = hooks.get_session() or {}
      local win = c.side == "old" and sess.original_win or sess.modified_win
      return win and vim.api.nvim_win_is_valid(win) and win or nil
    end

    local function jump()
      local win = target_win()
      if win then
        vim.api.nvim_set_current_win(win)
      end
      pcall(vim.api.nvim_win_set_cursor, 0, { line, 0 })
    end

    if explorer.data.current_file_path == c.file then
      jump()
      return
    end
    for _, file in ipairs(require("codediff.ui.explorer").get_all_files(explorer.tree)) do
      if file.data.path == c.file then
        explorer.on_file_select(file.data)
        -- diff の読み込みは非同期。対象ファイルが表示されるまで待ってから飛ぶ（最大2秒）
        local tries = 0
        local function wait()
          tries = tries + 1
          local win = target_win()
          local shown = win and vim.api.nvim_buf_get_name(vim.api.nvim_win_get_buf(win)) or ""
          if shown:sub(-#c.file) ~= c.file and tries < 40 then
            vim.defer_fn(wait, 50)
            return
          end
          jump()
          -- 切替のタイミング次第で review.nvim のキーとマークが付かないことがあるので付け直す
          require("review")._on_file_select()
        end
        vim.defer_fn(wait, 50)
        return
      end
    end
    vim.notify(c.file .. " はこの diff に含まれていません", vim.log.levels.WARN, { title = "review.nvim" })
  end)
end

return {
  {
    "esmuellert/codediff.nvim",
    tag = "v4.0.6",
    lazy = true,
    opts = {
      keymaps = {
        view = {
          -- <leader>b はバッファ操作のプレフィックスなので外す（パネル開閉は review.nvim の f）
          toggle_explorer = false,
          -- 既定の - は Oil と被り、誤ってstageしてしまうので移す
          toggle_stage = "<leader>hS",
        },
      },
    },
  },
  {
    "georgeguimaraes/review.nvim",
    tag = "v1.10.1",
    dependencies = {
      "esmuellert/codediff.nvim",
      "MunifTanjim/nui.nvim",
    },
    -- VeryLazy で読み込まないと、以前付けたノートがファイルを開いた時に表示されない
    event = "VeryLazy",
    keys = {
      { "<leader>rr", "<cmd>Review<cr>", desc = "Review working tree" },
      { "<leader>rc", "<cmd>Review commits<cr>", desc = "Review commits" },
      { "<leader>rb", "<cmd>Review branch<cr>", desc = "Review branch" },
      -- <cmd> ではなく : にすることで、ビジュアルモードでは :'<,'>Review note になる
      { "<leader>rn", ":Review note<cr>", mode = { "n", "v" }, desc = "Review: note here" },
      { "<leader>re", "<cmd>Review edit<cr>", desc = "Review: edit comment" },
      { "<leader>rd", "<cmd>Review delete<cr>", desc = "Review: delete comment" },
      { "<leader>rl", "<cmd>Review list<cr>", desc = "Review: list comments" },
      { "<leader>rx", "<cmd>Review export<cr>", desc = "Review: export" },
      { "<leader>rX", "<cmd>Review clear<cr>", desc = "Review: archive and clear" },
    },
    opts = {
      keymaps = {
        -- sidekick.nvim は未導入。S は Flash Treesitter のまま残す
        send_sidekick = false,
        -- <C-r>（redo）で全コメントが消えるのを避ける。<leader>rX を使う
        clear_comments = false,
        -- q の誤爆でエクスポート＋全消去されるのを避ける。q は codediff の「タブを閉じるだけ」に戻る
        close = false,
      },
    },
    config = function(_, opts)
      require("review").setup(opts)
      -- c キーと :Review list の両方がこの関数を呼ぶ
      require("review.comments").list = list_comments
    end,
  },
  {
    "folke/which-key.nvim",
    opts = {
      spec = {
        { "<leader>r", group = "review" },
      },
    },
  },
}
