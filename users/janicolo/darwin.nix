{
  config,
  pkgs,
  inputs,
  currentSystemName,
  isWSL,
  ...
}:
{
  homebrew = {
    enable = true;
    casks  = [];
    brews = [];
  };
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
