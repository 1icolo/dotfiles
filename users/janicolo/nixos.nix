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
    extraGroups = [
      "wheel"
      "networkmanager"
    ];
    shell = pkgs.zsh;
    # WSL has no PAM login session, so start the user systemd manager at boot.
    linger = isWSL;
  };
}
