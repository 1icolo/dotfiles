{ pkgs, pkgsUnstable, ... }:

{
  programs.fish = {
    enable = true;
    interactiveShellInit = ''
function hm-switch --description "Apply Home Manager configuration"
  nix run home-manager -- switch --flake "$HOME/.config/home-manager#janicogabo@aarch64-darwin" -b backup
end

if status is-interactive
end
    '';
  };

  programs.zsh = {
    enable = true;
    shellAliases = {
      hm-switch = "nix run home-manager -- switch --flake \"$HOME/.config/home-manager#janicogabo@aarch64-darwin\" -b backup";
      hm-edit = "$EDITOR ~/.config/home-manager/home.nix";
      hm-update = "nix flake update --flake ~/.config/home-manager";
      vi = "nvim";
      vim = "nvim";
      agent = "cursor-agent";
      cd = "z";
    };
    initContent = ''
      if [ -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' ]; then
        . '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
      fi
    '';
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

  home.packages = [
    pkgs.nix-diff
    pkgs.awscli2
    pkgs.bun
    pkgs.cava
    pkgs.colima
    pkgs.python3
    pkgs.ghostty-bin

    pkgs.telegram-desktop
    pkgs.iina
    pkgs.drawio
    pkgs.brave

    pkgs.fastfetch
    pkgs.ffmpeg
    pkgs.htop
    pkgs.imagemagick
    pkgs.marp-cli
    pkgs.nmap
    pkgs.p7zip
    pkgs.podman
    pkgs.rustup
    pkgs.unrar
    pkgs.dos2unix
    pkgs.glow

    pkgs.zellij

    pkgsUnstable.neovim

    pkgs.grok-cli
    pkgs.claude-code
    pkgs.sqlitebrowser
    pkgs.aerospace
    pkgs.qbittorrent
    pkgs.zed
    pkgs.ollama
  ];
}
