{
  description = "Home Manager configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    home-manager.url = "github:nix-community/home-manager/release-26.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    {
      nixpkgs,
      home-manager,
      ...
    }@inputs:
    let
      mkHome =
        {
          system,
          username,
          homeDir,
          extraModules ? [ ],
        }:
        let
          pkgs = nixpkgs.legacyPackages.${system};
          pkgsUnstable = inputs.nixpkgs-unstable.legacyPackages.${system};
        in
        home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          extraSpecialArgs = {
            inherit inputs pkgsUnstable;
          };
          modules = [
            ./common.nix
            {
              home.username = username;
              home.homeDirectory = homeDir;
            }
          ] ++ extraModules;
        };
    in
    {
      homeConfigurations."janicogabo@aarch64-darwin" = mkHome {
        system = "aarch64-darwin";
        username = "janicogabo";
        homeDir = "/Users/janicogabo";
        extraModules = [ ./darwin.nix ];
      };

      homeConfigurations."nico@x86_64-linux" = mkHome {
        system = "x86_64-linux";
        username = "nico";
        homeDir = "/home/nico";
        extraModules = [ ./wsl.nix ];
      };
    };
}
