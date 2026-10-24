{
  nixpkgs,
  inputs,
}:

name:
{
  system,
  user,
  systemUser ? user,
  darwin ? false,
  wsl ? false,
}:

let
  isWSL = wsl;
  isLinux = !darwin && !isWSL;

  machineConfig = ../machines/${name}.nix;
  userOSConfig = ../users/${user}/${if darwin then "darwin" else "nixos"}.nix;
  userHMConfig = ../users/${user}/home-manager.nix;

  systemFunc = if darwin then inputs.darwin.lib.darwinSystem else nixpkgs.lib.nixosSystem;
  home-manager =
    if darwin then inputs.home-manager.darwinModules else inputs.home-manager.nixosModules;
  inherit (nixpkgs.lib) optionals;
in
systemFunc rec {
  inherit system;
  modules = [
    { nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (nixpkgs.lib.getName pkg) [ "unrar" ]; }

  ]
  ++ optionals isWSL [
    inputs.nixos-wsl.nixosModules.wsl
  ]
  ++ optionals isLinux [
  ]
  ++ optionals darwin [
    # Disabled nix-rosetta-builder to avoid cross-platform build issues
    # inputs.nix-rosetta-builder.darwinModules.default
    # {
    # 	nix-rosetta-builder.onDemand = true;
    # }
  ]
  ++ [
    machineConfig
    userOSConfig
    home-manager.home-manager
    {
      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
      home-manager.users.${systemUser} = import userHMConfig {
        inherit inputs;
        isWSL = isWSL;
        currentSystemName = name;
      };
    }
    {
      config._module.args = {
        currentSystem = system;
        currentSystemName = name;
        currentSystemUser = user;
        isWSL = isWSL;
        inputs = inputs;
      };
    }
  ];
}
