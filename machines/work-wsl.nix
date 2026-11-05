{ pkgs, currentSystemUser, ... }:
let
  # systemd 260 leaves the user manager's cgroup with subtree controllers
  # enabled after a stop, so the next start fails with
  # "Failed to spawn executor: Device or resource busy" (systemd#41278).
  # WSL hits this reliably on boot, which breaks the user D-Bus session and
  # makes nixos-rebuild report "user activation for <user> failed".
  # Recovery hook: clear the stale controllers, then restart the manager.
  # Remove once systemd >= 261 is in nixpkgs.
  recoverUserManager = pkgs.writeShellApplication {
    name = "recover-user-manager";
    runtimeInputs = [
      pkgs.systemd
      pkgs.coreutils
    ];
    text = ''
      uid="''${1:?usage: recover-user-manager <uid>}"
      unit="user@''${uid}.service"
      cg="/sys/fs/cgroup/user.slice/user-''${uid}.slice/''${unit}"
      ctl="''${cg}/cgroup.subtree_control"

      if systemctl is-active --quiet "''${unit}"; then
        exit 0
      fi

      if [ -w "''${ctl}" ]; then
        read -ra controllers < "''${ctl}" || controllers=()
        if [ "''${#controllers[@]}" -gt 0 ]; then
          disable=""
          for c in "''${controllers[@]}"; do
            disable="''${disable} -''${c}"
          done
          printf '%s' "''${disable}" > "''${ctl}" || true
        fi
      fi

      systemctl reset-failed "''${unit}" || true
      systemctl restart "''${unit}"
    '';
  };
in
{
  imports = [ ];

  wsl = {
    enable = true;
    wslConf.automount.root = "/mnt";
    defaultUser = currentSystemUser;
    startMenuLaunchers = true;
  };

  environment.sessionVariables = {
    XDG_RUNTIME_DIR = "/mnt/wslg/runtime-dir";
  };

  # NixOS-WSL manages /etc/resolv.conf directly.
  networking.resolvconf.enable = false;
  networking.networkmanager.enable = true;
  networking.dhcpcd.setHostname = "nixos-nico";

  # Zsh as system shell (user login shell is set in users/janicolo/nixos.nix).
  programs.zsh.enable = true;

  nix = {
    package = pkgs.nixVersions.latest;
    extraOptions = ''
      experimental-features = nix-command flakes
      keep-outputs = true
      keep-derivations = true
    '';
  };

  # systemd 260 WSL workaround (see recoverUserManager above).
  systemd.services."user@" = {
    overrideStrategy = "asDropin";
    unitConfig.OnFailure = "recover-user-manager@%i.service";
  };

  systemd.services."recover-user-manager@" = {
    description = "Recover user@%i after systemd cgroup EBUSY (systemd#41278)";
    startLimitIntervalSec = 120;
    startLimitBurst = 5;
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${recoverUserManager}/bin/recover-user-manager %i";
    };
  };

  system.stateVersion = "26.05";
}
