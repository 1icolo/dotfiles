{ pkgs, pkgsUnstable, ... }:

{
  nixpkgs.config.allowUnfree = true;

  home.username = "janicogabo";
  home.homeDirectory = "/Users/janicogabo";
  home.stateVersion = "26.05";

  home.sessionPath = [
    "$HOME/.nix-profile/bin"
  ];

  home.sessionVariables = {
    EDITOR = "nvim";
    XDG_CONFIG_HOME="$HOME/.config";
    XDG_CACHE_HOME="$HOME/.cache";
    XDG_DATA_HOME="$HOME/.local/share";
    XDG_STATE_HOME="$HOME/.local/state";
  };

  programs.fish = {
    enable = true;
    interactiveShellInit = ''
function hm-switch --description "Apply Home Manager configuration"
  nix run home-manager -- switch --flake "$HOME/.config/home-manager#janicogabo@aarch64-darwin" -b backup
end

if status is-interactive
  # Commands to run in interactive sessions can go here
end
    '';
  };

  programs.zsh = {
    enable = true;
    shellAliases = { 
    	hm-switch="nix run home-manager -- switch --flake \"$HOME/.config/home-manager#janicogabo@aarch64-darwin\" -b backup";
      hm-edit="$EDITOR ~/.config/home-manager/home.nix";
      hm-update="nix flake update --flake ~/.config/home-manager";
      vi="nvim";
      vim="nvim";
      agent="cursor-agent";
      cd="z";
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
config.macos_window_background_blur = 20  -- or 30-40

-- -- The filled in variant of the < symbol
-- local SOLID_LEFT_ARROW = wezterm.nerdfonts.pl_right_hard_divider
--
-- -- The filled in variant of the > symbol
-- local SOLID_RIGHT_ARROW = wezterm.nerdfonts.pl_left_hard_divider
--
-- -- This function returns the suggested title for a tab.
-- -- It prefers the title that was set via `tab:set_title()`
-- -- or `wezterm cli set-tab-title`, but falls back to the
-- -- title of the active pane in that tab.
-- function tab_title(tab_info)
--   local title = tab_info.tab_title
--   -- if the tab title is explicitly set, take that
--   if title and #title > 0 then
--     return title
--   end
--   -- Otherwise, use the title from the active pane
--   -- in that tab
--   return tab_info.active_pane.title
-- end
--
-- wezterm.on(
--   'format-tab-title',
--   function(tab, tabs, panes, config, hover, max_width)
--     local edge_background = '#0b0022'
--     local background = '#1b1032'
--     local foreground = '#808080'
--
--     if tab.is_active then
--       background = '#2b2042'
--       foreground = '#c0c0c0'
--     elseif hover then
--       background = '#3b3052'
--       foreground = '#909090'
--     end
--
--     local edge_foreground = background
--
--     local title = tab_title(tab)
--
--     -- ensure that the titles fit in the available space,
--     -- and that we have room for the edges.
--     title = wezterm.truncate_right(title, max_width - 2)
--
--     return {
--       { Background = { Color = edge_background } },
--       { Foreground = { Color = edge_foreground } },
--       { Text = SOLID_LEFT_ARROW },
--       { Background = { Color = background } },
--       { Foreground = { Color = foreground } },
--       { Text = title },
--       { Background = { Color = edge_background } },
--       { Foreground = { Color = edge_foreground } },
--       { Text = SOLID_RIGHT_ARROW },
--     }
--   end
-- )

config.keys = {
  -- Open new terminal (like $mod+Enter in i3)
  -- { key = 'Return', mods = 'SUPER', action = act.SpawnWindow },

  -- Splits (like i3's $mod+v / $mod+h)
  { key = 'V', mods = 'SUPER', action = act.SplitHorizontal { domain = 'CurrentPaneDomain' } },
  { key = 'S', mods = 'SUPER', action = act.SplitVertical { domain = 'CurrentPaneDomain' } },

  -- Focus panes (like i3: $mod + j/k/l/; )
  { key = 'h', mods = 'SUPER', action = act.ActivatePaneDirection 'Left' },
  { key = 'j', mods = 'SUPER', action = act.ActivatePaneDirection 'Down' },
  { key = 'k', mods = 'SUPER', action = act.ActivatePaneDirection 'Up' },
  { key = 'l', mods = 'SUPER', action = act.ActivatePaneDirection 'Right' },

  -- Move panes (like $mod+Shift + j/k/l/; )
  -- { key = 'h', mods = 'SUPER|SHIFT', action = act.MovePaneDirection 'Left' },
  -- { key = 'j', mods = 'SUPER|SHIFT', action = act.MovePaneDirection 'Down' },
  -- { key = 'k', mods = 'SUPER|SHIFT', action = act.MovePaneDirection 'Up' },
  -- { key = 'l', mods = 'SUPER|SHIFT', action = act.MovePaneDirection 'Right' },

  -- Resize panes (like i3 resize mode)
  { key = 'h', mods = 'SUPER|CTRL', action = act.AdjustPaneSize { 'Left', 5 } },
  { key = 'j', mods = 'SUPER|CTRL', action = act.AdjustPaneSize { 'Down', 5 } },
  { key = 'k', mods = 'SUPER|CTRL', action = act.AdjustPaneSize { 'Up', 5 } },
  { key = 'l', mods = 'SUPER|CTRL', action = act.AdjustPaneSize { 'Right', 5 } },

  -- Close pane (like $mod+Shift+q)
  { key = 'c', mods = 'SUPER|SHIFT', action = act.CloseCurrentPane { confirm = true } },

  -- Tabs (like i3 workspaces, but for tabs)
  { key = 't', mods = 'SUPER', action = act.SpawnTab 'CurrentPaneDomain' },
  { key = 'w', mods = 'SUPER|SHIFT', action = act.CloseCurrentTab { confirm = true } },

  -- Switch tabs (like $mod + 1-9)
  { key = '1', mods = 'SUPER', action = act.ActivateTab(0) },
  { key = '2', mods = 'SUPER', action = act.ActivateTab(1) },
  { key = '3', mods = 'SUPER', action = act.ActivateTab(2) },
  { key = '4', mods = 'SUPER', action = act.ActivateTab(3) },
  { key = '5', mods = 'SUPER', action = act.ActivateTab(4) },
  { key = '6', mods = 'SUPER', action = act.ActivateTab(5) },
  { key = '7', mods = 'SUPER', action = act.ActivateTab(6) },
  { key = '8', mods = 'SUPER', action = act.ActivateTab(7) },
  { key = '9', mods = 'SUPER', action = act.ActivateTab(8) },

  -- Move pane to new tab, etc.
  -- { key = 't', mods = 'SUPER|SHIFT', action = act.MoveToNewTab },

  -- Fullscreen (like $mod+f)
  { key = 'f', mods = 'SUPER', action = act.ToggleFullScreen },

  -- Reload config
  { key = 'r', mods = 'SUPER|SHIFT', action = act.ReloadConfiguration },
}

-- Optional: Leader key (like tmux) if you want even more power
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

  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
    enableFishIntegration = true;
    enableBashIntegration = true;
  };
  programs.starship.enable = true;
  programs.fzf.enable = true;

  home.packages = [
    pkgs.nix-diff
    pkgs.awscli2
    pkgs.bun
    pkgs.cava
    pkgs.colima
    pkgs.deno
    pkgs.ripgrep

    pkgs.python3
    pkgs.ghostty-bin

    pkgs.telegram-desktop
    #pkgs.anki
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
    pkgs.uv
    pkgs.yazi
    pkgs.gh
    pkgs.ollama
    pkgs.dos2unix
    pkgs.glow

    pkgs.zellij
    pkgs.lazygit

    pkgsUnstable.neovim

    pkgs.opencode
    pkgs.sqlitebrowser
    pkgs.aerospace
    pkgs.qbittorrent
    pkgs.zed

  ];
}
