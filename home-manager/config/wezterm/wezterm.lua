local wezterm = require 'wezterm'

local act = wezterm.action
local config = wezterm.config_builder()

-- Windows
local is_windows = wezterm.target_triple:find("windows") ~= nil
local mod        = is_windows and 'ALT'    or 'SUPER'
local mod_shift  = is_windows and 'ALT|SHIFT'  or 'SUPER|SHIFT'
local mod_ctrl   = is_windows and 'ALT|CTRL'   or 'SUPER|CTRL'
if is_windows then
  config.wsl_domains = {
    {
      name = 'WSL:AlmaLinux-10',
      distribution = 'AlmaLinux-10',
      default_cwd = '~',
    },
  }
  config.default_domain = 'WSL:AlmaLinux-10'
end
-- Windows

use_fancy_tab_bar = true

config.window_background_opacity = 0.88
config.macos_window_background_blur = 25
-- config.font = wezterm.font 'Meslo'
config.font_size = 12

config.window_decorations = "RESIZE"
config.native_macos_fullscreen_mode = true
config.hide_tab_bar_if_only_one_tab = true
config.macos_window_background_blur = 20

config.color_scheme = 'OneHalfDark'

config.leader = { key = 'a', mods = mod, timeout_milliseconds = 1000 }
config.keys = {
  { key = '{', mods = 'LEADER|SHIFT', action = wezterm.action.PaneSelect { mode = 'SwapWithActiveKeepFocus' } },

  { key = 'v', mods = mod, action = act.SplitHorizontal { domain = 'CurrentPaneDomain' } },
  { key = 's', mods = mod, action = act.SplitVertical { domain = 'CurrentPaneDomain' } },

  { key = 'h', mods = mod, action = act.ActivatePaneDirection 'Left' },
  { key = 'j', mods = mod, action = act.ActivatePaneDirection 'Down' },
  { key = 'k', mods = mod, action = act.ActivatePaneDirection 'Up' },
  { key = 'l', mods = mod, action = act.ActivatePaneDirection 'Right' },



  { key = 'h', mods = mod_ctrl, action = act.AdjustPaneSize { 'Left', 5 } },
  { key = 'j', mods = mod_ctrl, action = act.AdjustPaneSize { 'Down', 5 } },
  { key = 'k', mods = mod_ctrl, action = act.AdjustPaneSize { 'Up', 5 } },
  { key = 'l', mods = mod_ctrl, action = act.AdjustPaneSize { 'Right', 5 } },

  { key = 'c', mods = mod_shift, action = act.CloseCurrentPane { confirm = true } },

  { key = 't', mods = mod, action = act.SpawnTab 'CurrentPaneDomain' },
  -- { key = 't', mods = mod_shift, action = act.SpawnCommandInNewTab { args = { 'cmd.exe' } } },
  { key = 't', mods = mod_shift, action = act.SpawnTab { DomainName = 'local' } },

  { key = 'w', mods = mod_shift, action = act.CloseCurrentTab { confirm = true } },

  { key = '1', mods = mod, action = act.ActivateTab(0) },
  { key = '2', mods = mod, action = act.ActivateTab(1) },
  { key = '3', mods = mod, action = act.ActivateTab(2) },
  { key = '4', mods = mod, action = act.ActivateTab(3) },
  { key = '5', mods = mod, action = act.ActivateTab(4) },
  { key = '6', mods = mod, action = act.ActivateTab(5) },
  { key = '7', mods = mod, action = act.ActivateTab(6) },
  { key = '8', mods = mod, action = act.ActivateTab(7) },
  { key = '9', mods = mod, action = act.ActivateTab(8) },

  { key = 'f', mods = mod, action = act.ToggleFullScreen },

  { key = 'r', mods = mod_shift, action = act.ReloadConfiguration },
}

config.key_tables = {
  leader = {
    { key = 's', action = act.SplitHorizontal { domain = 'CurrentPaneDomain' } },
    { key = 'v', action = act.SplitVertical { domain = 'CurrentPaneDomain' } },
    { key = 'q', action = act.CloseCurrentPane { confirm = true } },
  },
}

config.front_end = "Software"

return config
