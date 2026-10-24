{ nixpkgs, inputs }:

name:
{
  system,
  user,
  isWSL ? false,
  currentSystemName ? "standalone",
}:
  inputs.home-manager.lib.homeManagerConfiguration {
    pkgs = nixpkgs.legacyPackages.${system};
    modules = [
      (import ./users/${user}/home-manager.nix {
        isStandalone = true;
        isWSL = isWSL;
        currentSystemName = currentSystemName;
        inputs = inputs;
      })
      {
        home.username = user;
        home.homeDirectory = if system == "aarch64-darwin" then "/Users/${user}" else "/home/${user}";
        home.stateVersion = "26.05";
      }
    ];
  }