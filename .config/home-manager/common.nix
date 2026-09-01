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

  programs.starship.enable = true;
  programs.fzf.enable = true;
  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
    enableFishIntegration = true;
    enableBashIntegration = true;
  };

  home.packages = [
    pkgs.ripgrep
    pkgs.deno
    pkgs.uv
    pkgs.yazi
    pkgs.gh
    pkgs.lazygit
    pkgsUnstable.opencode
  ];
}
