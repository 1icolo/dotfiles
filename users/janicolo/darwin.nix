{
  config,
  pkgs,
  inputs,
  currentSystemName,
  isWSL,
  ...
}:
{
  # Darwin-specific configuration
  system.stateVersion = 7;
  system.defaults.dock = {
    autohide = true;
    tilesize = 36;
  };
  system.defaults.finder = {
    AppleShowAllFiles = true;
    ShowPathbar = true;
  };
  system.defaults.screencapture = {
    location = "~/Desktop";
  };

  users.users.janicogabo = {
    home = "/Users/janicogabo";
  };
  system.primaryUser = "janicogabo";
}

