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
	};
	outputs = { nixpkgs, ... }@inputs: let
		overlays = [
			(_final: prev: let
				system = prev.stdenv.hostPlatform.system;
				unstable = import inputs.nixpkgs-unstable {
					inherit system;
					config.allowUnfree = true;
				};
			in {
				gh = unstable.gh;
				opencode = unstable.opencode;
			})
		];
		mkSystem = import ./lib/mksystem.nix {
			inherit overlays nixpkgs inputs;
		};
		in {
      nixosConfigurations.vm-aarch64 = mkSystem "vm-aarch64" {
        system = "aarch64-linux";
        user   = "mitchellh";
      };
      nixosConfigurations.vm-aarch64-utm = mkSystem "vm-aarch64-utm" {
        system = "aarch64-linux";
        user   = "mitchellh";
      };
      linuxConfigurations.wsl = mkSystem "wsl" {
        system = "x86_64-linux";
        user   = "nico";
				wsl = true;
			};
      darwinConfigurations.macbook-pro-m1 = mkSystem "macbook-pro-m1" {
        system = "aarch64-darwin";
        user   = "janicogabo";
        darwin = true;
      };
		};
}
