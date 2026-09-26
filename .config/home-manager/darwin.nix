{ pkgs, pkgsUnstable, ... }:

{
  programs.zsh = {
    enable = true;
    shellAliases = {
      hm-switch = "nix run home-manager -- switch --flake \"$HOME/.config/home-manager#$(whoami)@aarch64-darwin\" -b backup";
      hm-update = "nix flake update --flake ~/.config/home-manager";
      hm-edit = "$EDITOR ~/.config/home-manager";
    };
    initContent = ''
      if [ -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' ]; then
        . '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
      fi
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

    pkgs.grok-cli
    pkgs.claude-code
    pkgs.sqlitebrowser
    pkgs.aerospace
    pkgs.qbittorrent
    pkgs.zed
    pkgs.ollama
  ];
}
