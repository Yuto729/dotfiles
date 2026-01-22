-- WezTerm Configuration (Ghostty-like)
local wezterm = require 'wezterm'
local act = wezterm.action
local config = wezterm.config_builder()

-- Theme and colors
config.color_scheme = 'Dracula'
config.colors = {
  background = '#000000',
}

-- Transparency (default: opaque)
config.window_background_opacity = 1.0

-- Opacity control functions
local DEFAULT_OPACITY = 0.8

wezterm.on('toggle-opacity', function(window, pane)
  local overrides = window:get_config_overrides() or {}
  if overrides.window_background_opacity == nil or overrides.window_background_opacity == 1.0 then
    overrides.window_background_opacity = DEFAULT_OPACITY
  else
    overrides.window_background_opacity = 1.0
  end
  window:set_config_overrides(overrides)
end)

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
  { key = 'LeftArrow', mods = 'ALT', action = wezterm.action.DisableDefaultAssignment },
  { key = 'RightArrow', mods = 'ALT', action = wezterm.action.DisableDefaultAssignment },

  -- 分割操作
  { key = 'q', mods = 'CTRL|SHIFT', action = wezterm.action.CloseCurrentPane { confirm = true } },
  { key = 'h', mods = 'CTRL', action = wezterm.action.ActivatePaneDirection 'Left' },
  { key = 'j', mods = 'CTRL', action = wezterm.action.ActivatePaneDirection 'Down' },
  { key = 'k', mods = 'CTRL', action = wezterm.action.ActivatePaneDirection 'Up' },
  { key = 'l', mods = 'CTRL', action = wezterm.action.ActivatePaneDirection 'Right' },
  { key = 'z', mods = 'CTRL', action = wezterm.action.TogglePaneZoomState },

  -- タブ操作
  { key = 'h', mods = 'CTRL|SHIFT', action = wezterm.action.ActivateTabRelative(-1) },
  { key = 'l', mods = 'CTRL|SHIFT', action = wezterm.action.ActivateTabRelative(1) },

  -- 分割作成（追加）
  { key = '|', mods = 'CTRL|SHIFT', action = wezterm.action.SplitHorizontal { domain = 'CurrentPaneDomain' } },
  { key = '_', mods = 'CTRL|SHIFT', action = wezterm.action.SplitVertical { domain = 'CurrentPaneDomain' } },

  -- 透過操作
  { key = 'B', mods = 'CTRL|SHIFT', action = wezterm.action.EmitEvent 'toggle-opacity' },
  { key = 'UpArrow', mods = 'CTRL|SHIFT', action = act.EmitEvent 'increase-opacity' },
  { key = 'DownArrow', mods = 'CTRL|SHIFT', action = act.EmitEvent 'decrease-opacity' },
}

return config
