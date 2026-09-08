{ pkgs, pkgsUnstable, ... }:

{
  nixpkgs.config.allowUnfree = true;
  home.stateVersion = "26.05";

  home.sessionPath = [
    "$HOME/.nix-profile/bin"
  ];

  home.sessionVariables = {
    EDITOR = "nvim";
    XDG_CONFIG_HOME = "$HOME/.config";
    XDG_CACHE_HOME = "$HOME/.cache";
    XDG_DATA_HOME = "$HOME/.local/share";
    XDG_STATE_HOME = "$HOME/.local/state";
  };

  programs.starship= {
    enable = true;
    settings = {
      add_newline = true;
      scan_timeout = 10;
      aws = {
      	disabled = true;
      };
      gcloud = {
      	disabled = true;
      };
      azure = {
      	disabled = true;
      };
    };
  };
  programs.fzf.enable = true;
  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
    enableFishIntegration = true;
    enableBashIntegration = true;
    options = [
      "--no-cmd"
    ];
  };

  programs.wezterm = {
    enable = true;
    enableZshIntegration = true;
    enableBashIntegration = true;
    extraConfig = ''
local act = wezterm.action
local config = wezterm.config_builder()

use_fancy_tab_bar = true

config.window_background_opacity = 0.88
config.macos_window_background_blur = 25
config.font = wezterm.font 'Menlo'
config.font_size = 16

config.window_decorations = "RESIZE"
config.native_macos_fullscreen_mode = true
config.hide_tab_bar_if_only_one_tab = true
config.macos_window_background_blur = 20

config.keys = {
  { key = 'V', mods = 'SUPER', action = act.SplitHorizontal { domain = 'CurrentPaneDomain' } },
  { key = 'S', mods = 'SUPER', action = act.SplitVertical { domain = 'CurrentPaneDomain' } },

  { key = 'h', mods = 'SUPER', action = act.ActivatePaneDirection 'Left' },
  { key = 'j', mods = 'SUPER', action = act.ActivatePaneDirection 'Down' },
  { key = 'k', mods = 'SUPER', action = act.ActivatePaneDirection 'Up' },
  { key = 'l', mods = 'SUPER', action = act.ActivatePaneDirection 'Right' },

  { key = 'h', mods = 'SUPER|CTRL', action = act.AdjustPaneSize { 'Left', 5 } },
  { key = 'j', mods = 'SUPER|CTRL', action = act.AdjustPaneSize { 'Down', 5 } },
  { key = 'k', mods = 'SUPER|CTRL', action = act.AdjustPaneSize { 'Up', 5 } },
  { key = 'l', mods = 'SUPER|CTRL', action = act.AdjustPaneSize { 'Right', 5 } },

  { key = 'c', mods = 'SUPER|SHIFT', action = act.CloseCurrentPane { confirm = true } },

  { key = 't', mods = 'SUPER', action = act.SpawnTab 'CurrentPaneDomain' },
  { key = 'w', mods = 'SUPER|SHIFT', action = act.CloseCurrentTab { confirm = true } },

  { key = '1', mods = 'SUPER', action = act.ActivateTab(0) },
  { key = '2', mods = 'SUPER', action = act.ActivateTab(1) },
  { key = '3', mods = 'SUPER', action = act.ActivateTab(2) },
  { key = '4', mods = 'SUPER', action = act.ActivateTab(3) },
  { key = '5', mods = 'SUPER', action = act.ActivateTab(4) },
  { key = '6', mods = 'SUPER', action = act.ActivateTab(5) },
  { key = '7', mods = 'SUPER', action = act.ActivateTab(6) },
  { key = '8', mods = 'SUPER', action = act.ActivateTab(7) },
  { key = '9', mods = 'SUPER', action = act.ActivateTab(8) },

  { key = 'f', mods = 'SUPER', action = act.ToggleFullScreen },

  { key = 'r', mods = 'SUPER|SHIFT', action = act.ReloadConfiguration },
}

config.leader = { key = 'a', mods = 'SUPER', timeout_milliseconds = 1000 }
config.key_tables = {
  leader = {
    { key = 's', action = act.SplitHorizontal { domain = 'CurrentPaneDomain' } },
    { key = 'v', action = act.SplitVertical { domain = 'CurrentPaneDomain' } },
    { key = 'q', action = act.CloseCurrentPane { confirm = true } },
  },
}

return config
    '';
  };

  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
    defaultEditor = true;
  };
  programs.gh = {
    enable = true;
  };

  home.packages = [
    pkgs.ripgrep
    pkgs.deno
    pkgs.uv
    pkgs.yazi
    pkgs.lazygit
    pkgsUnstable.opencode
  ];
}
