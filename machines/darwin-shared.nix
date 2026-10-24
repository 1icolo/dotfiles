{ config, lib, pkgs, ... }:
{
  # Shared Darwin configuration
  nix = {
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
    };
  };

  # Enable home-manager
  home-manager = {
    useUserPackages = true;
  };
}