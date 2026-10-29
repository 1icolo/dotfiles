# INSTRUCTIONS — NixOS-WSL setup for this dotfiles repo

Status: **working** (built and activated on this machine, generation 3, 2026-10-29).

## What was fixed to make it work

1. **Added the `nixos-wsl` flake input** (`flake.nix`) — `lib/mksystem.nix` referenced
   `inputs.nixos-wsl.nixosModules.wsl` but the input was never declared. It now points at
   `github:nix-community/NixOS-WSL/release-26.05` and follows our `nixpkgs`.
2. **Renamed `machines/linux-wsl.nix` → `machines/work-wsl.nix`** — the flake calls
   `mkSystem "work-wsl"`, which expects `machines/work-wsl.nix` (name must match).
3. **Changed the flake output from `linuxConfigurations.wsl` to `nixosConfigurations.work-wsl`** —
   `nixos-rebuild` and the justfile both look for `nixosConfigurations.<name>`; the old
   attribute was silently ignored by Nix (and skipped by `nix flake check`).
4. **Fixed `lib/mksystem.nix`** — used `pkgs.lib.nixosSystem` on a manually imported package
   set, which doesn't carry `nixosSystem`. Now uses `nixpkgs.lib.nixosSystem` directly.
5. **Created `users/janicolo/nixos.nix`** — `mksystem.nix` expects a
   `users/<user>/nixos.nix` for Linux systems (only `darwin.nix` existed). It declares the
   `janicolo` user (normal user, wheel group).
6. **Fixed `lib/mkhome.nix`** — two bugs: `flake.nix` passed a fake `{ config = ...; }`
   attrset instead of the real `nixpkgs` input (so `legacyPackages` was missing), and the
   module path `./users/...` resolved relative to `lib/` instead of the repo root
   (now `../users/...`).
7. **Ran `nix flake update`** — this added `nixos-wsl` to `flake.lock` and bumped the other
   inputs (nixpkgs is now `nixos-26.05` as of 2026-10-28).

## Day-to-day usage (on this WSL machine)

```bash
cd /tmp/dotfiles   # or wherever the repo lives (see "Repo location" below)

# Apply system + home-manager changes
sudo nixos-rebuild switch --flake .#work-wsl
# or, with just:
just switch target=work-wsl

# Build without switching
just build target=work-wsl

# Roll back to the previous generation
sudo nixos-rebuild switch --rollback

# Update all flake inputs, then apply
just update
sudo nixos-rebuild switch --flake .#work-wsl

# Validate everything (no build)
just check        # nix flake check
just check-all    # evaluates all 4 outputs
```

The `work-wsl` config applies home-manager for `janicolo` as part of the system build
(`home-manager-janicolo.service`), so there is no separate `home-manager switch` step on
this machine. The standalone home-manager outputs
(`homeConfigurations."janicolo@x86_64-linux[-wsl]"`) are only for non-NixOS machines
(e.g. Ubuntu/AlmaLinux under WSL) and are **not** used here.

## Important notes for this machine

- **Login shell is zsh.** Set via `shell = pkgs.zsh;` in `users/janicolo/nixos.nix` plus
  `programs.zsh.enable = true;` in `machines/work-wsl.nix` (system zsh, `/etc/zshenv`,
  `/etc/shells` registration). Home-manager's `programs.zsh` handles the init files and
  integrations (starship, zoxide, fzf, zsh completions).
- **Default WSL user is now `janicolo`** (`/etc/wsl.conf` → `[user] default=janicolo`).
  Close and reopen your WSL terminal (or run `wsl --shutdown` from Windows) to land in a
  `janicolo` login shell with the full environment (zsh, nvim, starship, zed, etc.).
- The old `nixos` user was removed by the first switch (it was undeclared in the new
  config) and `janicolo` inherited its uid (1000), so files under `/tmp/dotfiles` and
  `/home/nixos` are already owned by `janicolo`. Leftover `/home/nixos` can be deleted
  whenever you no longer need it: `sudo rm -rf /home/nixos`.
- **Repo location**: `/tmp` currently lives on the root ext4 partition, so it survives a
  reboot — but it is still a tmp-style location. Consider moving the repo somewhere
  permanent, e.g. `mv /tmp/dotfiles /home/janicolo/dotfiles`.
- **Uncommitted changes**: all fixes above are in the working tree of
  `github.com:1icolo/dotfiles` but not committed/pushed yet. Commit and push so the
  machine can re-clone if needed.
- **Nix only sees git-tracked files.** After adding a new file (e.g. a new machine or
  user module), `git add` it before evaluating/building, or you will get
  `path ... is not tracked by Git` errors.
- A harmless warning may appear during `nixos-rebuild switch`:
  `user activation for <user> failed … dbus … $DISPLAY for X11`. In WSL there is no
  user dbus session; the switch still completes (check `readlink /run/current-system`
  and `systemctl status home-manager-janicolo.service` if unsure).
- Enable flakes for a fresh user with:
  `mkdir -p ~/.config/nix && printf 'experimental-features = nix-command flakes\n' > ~/.config/nix/nix.conf`
  (the system config also sets them in `/etc/nix/nix.conf` via `machines/work-wsl.nix`).

## Adding another Linux/WSL machine later

1. Create `machines/<name>.nix` (copy `machines/work-wsl.nix`, adjust `wsl` options).
2. Register it in `flake.nix`:
   ```nix
   nixosConfigurations.<name> = mkSystem "<name>" {
     system = "x86_64-linux";
     user = "janicolo";
     wsl = true;
   };
   ```
3. Run `nix flake update` (only needed when adding inputs) and
   `sudo nixos-rebuild switch --flake .#<name>`.
