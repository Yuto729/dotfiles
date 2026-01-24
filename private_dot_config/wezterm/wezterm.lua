-- WezTerm Configuration
local wezterm = require 'wezterm'
local act = wezterm.action
local config = wezterm.config_builder()

-- Leader key
config.leader = { key = 'q', mods = 'CTRL', timeout_milliseconds = 1000 }

-- タブタイトル用キャッシュ
local title_cache = {}

-- 現ディレクトリとgitブランチ名を取得
local function get_tab_title(pane)
  local cwd_uri = pane:get_current_working_dir()
  if not cwd_uri then
    return nil
  end

  local cwd = tostring(cwd_uri):gsub("^file://[^/]*", "")

  if not cwd or cwd == "" then
    return nil
  end

  local current_dir = cwd:match("([^/]+)/?$") or cwd

  -- Gitのブランチ名を取得
  local success, stdout, stderr = wezterm.run_child_process({
    "git", "-C", cwd, "branch", "--show-current"
  })

  if success and stdout then
    local branch = stdout:gsub("%s+", "")
    if branch ~= "" then
      return branch .. ':' .. current_dir
    end
  end

  return current_dir
end

-- タイトルをキャッシュ（外部ツールが設定したタイトルは優先）
wezterm.on("update-status", function(window, pane)
  local pane_id = pane:pane_id()
  local pane_title = pane:get_title()
  -- デフォルトのタイトルパターン: "user@host: path" 形式
  local is_default = pane_title:match("^%w+@%w+:") ~= nil

  if not is_default and pane_title ~= "" then
    -- 外部ツールが設定したタイトルを使用
    title_cache[pane_id] = pane_title
  else
    -- デフォルトの場合は branch:directory 形式
    local title = get_tab_title(pane)
    if title then
      title_cache[pane_id] = title
    end
  end
end)

-- タブのタイトルを変更
wezterm.on("format-tab-title", function(tab, tabs, panes, config, hover, max_width)
  local pane_id = tab.active_pane.pane_id
  return title_cache[pane_id] or tab.active_pane.title
end)

-- ウィンドウタイトルを変更
wezterm.on("format-window-title", function(tab, pane, tabs, panes, config)
  local zoomed = tab.active_pane.is_zoomed and '[Z] ' or ''
  local index = #tabs > 1 and string.format('[%d/%d] ', tab.tab_index + 1, #tabs) or ''
  local title = title_cache[pane.pane_id] or tab.active_pane.title
  return zoomed .. index .. title
end)

-- Theme and colors
config.color_scheme = 'Dracula'
config.colors = {
  background = '#000000',
}

-- Transparency (default: opaque)
config.window_background_opacity = 1.0

-- Opacity control functions
wezterm.on('increase-opacity', function(window, pane)
  local overrides = window:get_config_overrides() or {}
  local current = overrides.window_background_opacity or 1.0
  overrides.window_background_opacity = math.min(current + 0.1, 1.0)
  window:set_config_overrides(overrides)
end)

wezterm.on('decrease-opacity', function(window, pane)
  local overrides = window:get_config_overrides() or {}
  local current = overrides.window_background_opacity or 1.0
  overrides.window_background_opacity = math.max(current - 0.1, 0.1)
  window:set_config_overrides(overrides)
end)

-- Font (HackGen - Japanese optimized)
config.font = wezterm.font('HackGen Console NF')
config.font_size = 14.0

-- Cursor
config.default_cursor_style = 'BlinkingBlock'

-- Window
config.window_decorations = 'RESIZE'
config.window_padding = {
  left = 5,
  right = 5,
  top = 5,
  bottom = 5,
}

-- Tab bar
config.enable_tab_bar = true
config.hide_tab_bar_if_only_one_tab = true
config.tab_bar_at_bottom = false

-- Keybindings
config.keys = {
  -- Alt+left/right を無効化
  { key = 'LeftArrow', mods = 'ALT', action = act.DisableDefaultAssignment },
  { key = 'RightArrow', mods = 'ALT', action = act.DisableDefaultAssignment },

  -- ペイン間移動
  { key = 'h', mods = 'CTRL', action = act.ActivatePaneDirection 'Left' },
  { key = 'j', mods = 'CTRL', action = act.ActivatePaneDirection 'Down' },
  { key = 'k', mods = 'CTRL', action = act.ActivatePaneDirection 'Up' },
  { key = 'l', mods = 'CTRL', action = act.ActivatePaneDirection 'Right' },

  -- タブ間移動
  { key = 'h', mods = 'CTRL|SHIFT', action = act.ActivateTabRelative(-1) },
  { key = 'l', mods = 'CTRL|SHIFT', action = act.ActivateTabRelative(1) },

  -- 透過操作
  { key = 'UpArrow', mods = 'CTRL|SHIFT', action = act.EmitEvent 'increase-opacity' },
  { key = 'DownArrow', mods = 'CTRL|SHIFT', action = act.EmitEvent 'decrease-opacity' },

  -- コピー/ペースト
  { key = 'C', mods = 'CTRL|SHIFT', action = act.CopyTo 'Clipboard' },
  { key = 'V', mods = 'CTRL|SHIFT', action = act.PasteFrom 'Clipboard' },

  -- === Leader key 操作 ===

  -- 分割
  { key = 'v', mods = 'LEADER', action = act.SplitVertical { domain = 'CurrentPaneDomain' } },
  { key = 'h', mods = 'LEADER', action = act.SplitHorizontal { domain = 'CurrentPaneDomain' } },

  -- ペイン操作
  { key = 'x', mods = 'LEADER', action = act.CloseCurrentPane { confirm = true } },
  { key = 'z', mods = 'LEADER', action = act.TogglePaneZoomState },

  -- リサイズモード
  { key = 's', mods = 'LEADER', action = act.ActivateKeyTable { name = 'resize_pane', one_shot = false } },

  -- タブ移動モード
  { key = 't', mods = 'LEADER', action = act.ActivateKeyTable { name = 'move_tab', one_shot = false } },

  -- コピーモード
  { key = '[', mods = 'LEADER', action = act.ActivateCopyMode },

  -- Workspace
  { key = 'w', mods = 'LEADER', action = act.ShowLauncherArgs { flags = 'WORKSPACES', title = 'Select workspace' } },
  { key = '$', mods = 'LEADER', action = act.PromptInputLine {
      description = 'Set workspace title:',
      action = wezterm.action_callback(function(win, pane, line)
        if line then
          wezterm.mux.rename_workspace(wezterm.mux.get_active_workspace(), line)
        end
      end),
    },
  },
  { key = 'W', mods = 'LEADER|SHIFT', action = act.PromptInputLine {
      description = 'Create new workspace:',
      action = wezterm.action_callback(function(window, pane, line)
        if line then
          window:perform_action(act.SwitchToWorkspace { name = line }, pane)
        end
      end),
    },
  },
}

-- Key tables
config.key_tables = {
  -- リサイズモード (Leader+s)
  resize_pane = {
    { key = 'h', action = act.AdjustPaneSize { 'Left', 1 } },
    { key = 'l', action = act.AdjustPaneSize { 'Right', 1 } },
    { key = 'k', action = act.AdjustPaneSize { 'Up', 1 } },
    { key = 'j', action = act.AdjustPaneSize { 'Down', 1 } },
    { key = 'Enter', action = 'PopKeyTable' },
    { key = 'Escape', action = 'PopKeyTable' },
  },

  -- タブ移動モード (Leader+t)
  move_tab = {
    { key = 'h', action = act.MoveTabRelative(-1) },
    { key = 'l', action = act.MoveTabRelative(1) },
    { key = 'Enter', action = 'PopKeyTable' },
    { key = 'Escape', action = 'PopKeyTable' },
  },

  -- コピーモード (Leader+[)
  copy_mode = {
    -- 移動
    { key = 'h', mods = 'NONE', action = act.CopyMode 'MoveLeft' },
    { key = 'j', mods = 'NONE', action = act.CopyMode 'MoveDown' },
    { key = 'k', mods = 'NONE', action = act.CopyMode 'MoveUp' },
    { key = 'l', mods = 'NONE', action = act.CopyMode 'MoveRight' },
    -- 行頭・行末
    { key = '^', mods = 'NONE', action = act.CopyMode 'MoveToStartOfLineContent' },
    { key = '$', mods = 'NONE', action = act.CopyMode 'MoveToEndOfLineContent' },
    { key = '0', mods = 'NONE', action = act.CopyMode 'MoveToStartOfLine' },
    -- 単語移動
    { key = 'w', mods = 'NONE', action = act.CopyMode 'MoveForwardWord' },
    { key = 'b', mods = 'NONE', action = act.CopyMode 'MoveBackwardWord' },
    { key = 'e', mods = 'NONE', action = act.CopyMode 'MoveForwardWordEnd' },
    -- スクロール
    { key = 'G', mods = 'NONE', action = act.CopyMode 'MoveToScrollbackBottom' },
    { key = 'g', mods = 'NONE', action = act.CopyMode 'MoveToScrollbackTop' },
    { key = 'b', mods = 'CTRL', action = act.CopyMode 'PageUp' },
    { key = 'f', mods = 'CTRL', action = act.CopyMode 'PageDown' },
    { key = 'd', mods = 'CTRL', action = act.CopyMode { MoveByPage = 0.5 } },
    { key = 'u', mods = 'CTRL', action = act.CopyMode { MoveByPage = -0.5 } },
    -- 選択モード
    { key = 'v', mods = 'NONE', action = act.CopyMode { SetSelectionMode = 'Cell' } },
    { key = 'v', mods = 'CTRL', action = act.CopyMode { SetSelectionMode = 'Block' } },
    { key = 'V', mods = 'NONE', action = act.CopyMode { SetSelectionMode = 'Line' } },
    -- コピー
    { key = 'y', mods = 'NONE', action = act.CopyTo 'Clipboard' },
    -- 終了
    { key = 'Enter', mods = 'NONE', action = act.Multiple { { CopyTo = 'ClipboardAndPrimarySelection' }, { CopyMode = 'Close' } } },
    { key = 'Escape', mods = 'NONE', action = act.CopyMode 'Close' },
    { key = 'q', mods = 'NONE', action = act.CopyMode 'Close' },
  },
}

return config
