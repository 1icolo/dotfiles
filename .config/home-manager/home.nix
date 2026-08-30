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

  programs.starship.enable = true;
  programs.fzf.enable = true;
  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
  };

  home.packages = [
    pkgs.nix-diff
    pkgs.awscli2
    pkgs.bun
    pkgs.cava
    pkgs.colima
    pkgs.deno
    pkgs.ripgrep
    pkgs.python313
    pkgs.lua5_4
    pkgs.ghostty-bin

    pkgs.telegram-desktop

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
    pkgs.iina
    pkgs.drawio
    #pkgs.anki
    pkgs.brave

    pkgs.wezterm

    pkgs.zellij

    pkgsUnstable.neovim

    pkgs.opencode
    pkgs.cursor-cli
    pkgs.kiro-cli
    pkgs.sqlitebrowser

    pkgs.aerospace
    pkgs.obsidian
    pkgs.qbittorrent
    pkgs.zed
  ];
}
