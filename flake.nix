{
  description = "NixOS systems and tools by nicolo";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    direnv-instant = {
      url = "github:Mic92/direnv-instant";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    darwin = {
      url = "github:nix-darwin/nix-darwin/nix-darwin-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    neovim-nightly-overlay = {
      url = "github:nix-community/neovim-nightly-overlay";
    };
    nix-rosetta-builder = {
      url = "github:cpick/nix-rosetta-builder";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs =
    { nixpkgs, ... }@inputs:
    let
      overlays = [
        (
          _final: prev:
          let
            system = prev.stdenv.hostPlatform.system;
            unstable = import inputs.nixpkgs-unstable {
              inherit system;
              config.allowUnfree = true;
            };
          in
          {
            opencode = unstable.opencode;
          }
        )
      ];
      mkSystem = import ./lib/mksystem.nix {
        inherit nixpkgs inputs;
      };
      mkHome = import ./lib/mkhome.nix {
        inherit nixpkgs inputs;
      };
    in
    {
      linuxConfigurations.wsl = mkSystem "work-wsl" {
        system = "x86_64-linux";
        user = "janicolo";
        wsl = true;
      };
      darwinConfigurations.macbook-pro-m1 = mkSystem "macbook-pro-m1" {
        system = "aarch64-darwin";
        user = "janicolo";
        systemUser = "janicogabo";
        darwin = true;
      };
      homeConfigurations."janicolo@x86_64-linux" = mkHome "janicolo" {
        system = "x86_64-linux";
        user = "janicolo";
        isWSL = false;
        currentSystemName = "standalone";
      };
      homeConfigurations."janicolo@x86_64-linux-wsl" = mkHome "janicolo-wsl" {
        system = "x86_64-linux";
        user = "janicolo";
        isWSL = true;
        currentSystemName = "wsl";
      };
    };
}
