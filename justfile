# justfile for nix-darwin + nixos-wsl + standalone home-manager
# Usage: just switch [target]
#   Target defaults to macbook-pro-m1 on macOS and work-wsl on Linux.
#   Both `just switch work-wsl` and `just switch target=work-wsl` work.

# Auto-detect system
uname := `uname -s`

# Default target for this OS
nixname := if uname == "Darwin" { "macbook-pro-m1" } else { "work-wsl" }

# Standalone home-manager flake references
hm_flake_linux := ".#homeConfigurations.janicolo@x86_64-linux"
hm_flake_wsl := ".#homeConfigurations.janicolo@x86_64-linux-wsl"

# Default recipe
default: switch

# --- System switch (nix-darwin / nixos-wsl) ---
switch *args:
	#!/usr/bin/env sh
	set -eu
	target="{{args}}"
	target="${target#target=}"
	target="${target:-{{nixname}}}"
	if [ "{{uname}}" = "Darwin" ]; then
		nix build ".#darwinConfigurations.${target}.system"
		sudo ./result/sw/bin/darwin-rebuild switch --flake "$(pwd)#${target}"
	else
		sudo nixos-rebuild switch --flake ".#${target}"
	fi

# Test configuration without making it boot default
test *args:
	#!/usr/bin/env sh
	set -eu
	target="{{args}}"
	target="${target#target=}"
	target="${target:-{{nixname}}}"
	if [ "{{uname}}" = "Darwin" ]; then
		nix build ".#darwinConfigurations.${target}.system"
		sudo ./result/sw/bin/darwin-rebuild test --flake "$(pwd)#${target}"
	else
		sudo nixos-rebuild test --flake ".#${target}"
	fi

# Build without switching
build *args:
	#!/usr/bin/env sh
	set -eu
	target="{{args}}"
	target="${target#target=}"
	target="${target:-{{nixname}}}"
	if [ "{{uname}}" = "Darwin" ]; then
		nix build ".#darwinConfigurations.${target}.system"
	else
		nix build ".#nixosConfigurations.${target}.config.system.build.toplevel"
	fi

# --- Standalone home-manager ---

# Build and switch home-manager (Linux only)
hm-switch:
	#!/usr/bin/env sh
	if [ "{{uname}}" = "Darwin" ]; then
		echo "hm-switch is for Linux only. Use 'switch' on macOS."
		exit 1
	fi
	nix build "{{hm_flake_linux}}.activationPackage"
	./result/activate

# WSL-specific home-manager
hm-switch-wsl:
	#!/usr/bin/env sh
	if [ "{{uname}}" = "Darwin" ]; then
		echo "hm-switch-wsl is for Linux only."
		exit 1
	fi
	nix build "{{hm_flake_wsl}}.activationPackage"
	./result/activate

# Test home-manager without making it default
hm-test:
	#!/usr/bin/env sh
	if [ "{{uname}}" = "Darwin" ]; then
		echo "hm-test is for Linux only."
		exit 1
	fi
	nix build "{{hm_flake_linux}}.activationPackage"
	./result/activate --dry-run

# Build home-manager without switching
hm-build:
	#!/usr/bin/env sh
	if [ "{{uname}}" = "Darwin" ]; then
		echo "hm-build is for Linux only."
		exit 1
	fi
	nix build "{{hm_flake_linux}}.activationPackage"

# Show home-manager generations
hm-gen:
	home-manager generations

# Rollback home-manager
hm-rollback:
	home-manager switch --rollback

# --- Common ---

# Check flake evaluates correctly (no build)
check:
	nix flake check --all-systems --no-build

# Validate all configurations
check-all:
	nix eval --raw '.#nixosConfigurations.work-wsl.config.system.build.toplevel.drvPath' >/dev/null
	nix eval --raw '.#darwinConfigurations.macbook-pro-m1.config.system.build.toplevel.drvPath' >/dev/null
	nix eval --raw '.#homeConfigurations."janicolo@x86_64-linux".activationPackage.drvPath' >/dev/null
	nix eval --raw '.#homeConfigurations."janicolo@x86_64-linux-wsl".activationPackage.drvPath' >/dev/null

# Push to cachix (requires auth)
cache:
	nix build '.#nixosConfigurations.work-wsl.config.system.build.toplevel' --no-link --print-out-paths \
		| nix run nixpkgs#cachix -- push janicolo-nixos-config

# Update flake inputs
update:
	nix flake update

# Show current generation
gen:
	#!/usr/bin/env sh
	if [ "{{uname}}" = "Darwin" ]; then
		darwin-rebuild --list-generations
	else
		sudo nix-env --list-generations --profile /nix/var/nix/profiles/system
	fi

# Rollback to previous generation
rollback:
	#!/usr/bin/env sh
	if [ "{{uname}}" = "Darwin" ]; then
		sudo darwin-rebuild switch --rollback
	else
		sudo nixos-rebuild switch --rollback
	fi

# Garbage collect old generations
gc:
	sudo nix-collect-garbage --delete-older-than 30d

# Show what GC would remove and current store disk usage
gc-stats:
	nix store gc --dry-run
	df -h /nix/store

# Edit this justfile
edit:
	$EDITOR justfile

# Show detected system info
info *args:
	#!/usr/bin/env sh
	target="{{args}}"
	target="${target#target=}"
	target="${target:-{{nixname}}}"
	echo "System: {{uname}}"
	echo "Target: ${target}"
	echo "Flake dir: $(pwd)"

# List all available targets
targets:
	@echo "System configs:"
	@echo "  macbook-pro-m1  (darwin)"
	@echo "  work-wsl        (nixos)"
	@echo ""
	@echo "Home-manager configs:"
	@echo "  janicolo@x86_64-linux      (standalone Linux)"
	@echo "  janicolo@x86_64-linux-wsl  (WSL)"
