{
  config,
  pkgs,
  inputs,
  currentSystemName,
  isWSL,
  ...
}:
{
  users.users.janicolo = {
    isNormalUser = true;
    home = "/home/janicolo";
    extraGroups = [ "wheel" ];
    shell = pkgs.zsh;
  };
}
