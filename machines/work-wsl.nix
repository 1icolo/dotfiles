{ pkgs, currentSystemUser, ... }: {
  imports = [ ];

  wsl = {
    enable = true;
    wslConf.automount.root = "/mnt";
    defaultUser = currentSystemUser;
    startMenuLaunchers = true;
  };

  # NixOS-WSL manages /etc/resolv.conf directly.
  networking.resolvconf.enable = false;

  # Zsh as system shell (user login shell is set in users/janicolo/nixos.nix).
  programs.zsh.enable = true;

  nix = {
    package = pkgs.nixVersions.latest;
    extraOptions = ''
      experimental-features = nix-command flakes
      keep-outputs = true
      keep-derivations = true
    '';
  };

  system.stateVersion = "26.05";
}
