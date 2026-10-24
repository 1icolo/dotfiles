# justfile for nix-darwin + nixos-wsl + standalone home-manager
# Usage: just switch [target]

# Auto-detect system
uname := `uname -s`

# Target selection (can override: just switch target=macbook-pro-m1)
target := ""

# Map to flake configurations
nixname := if uname == "Darwin" { "macbook-pro-m1" } else { "work-wsl" }
target_name := if target != "" { target } else { nixname }

darwin_flake := ".#darwinConfigurations." + target_name
nixos_flake := ".#nixosConfigurations." + target_name
hm_flake_linux := ".#homeConfigurations.janicolo@x86_64-linux"
hm_flake_wsl := ".#homeConfigurations.janicolo@x86_64-linux-wsl"

# Default recipe
default: switch

# --- System switch (nix-darwin / nixos-wsl) ---
switch:
	#!/usr/bin/env sh
	if [ "{{uname}}" = "Darwin" ]; then
		nix build "{{darwin_flake}}.system"
		sudo ./result/sw/bin/darwin-rebuild switch --flake "$(pwd)#{{target_name}}"
	else
		sudo nixos-rebuild switch --flake "{{nixos_flake}}"
	fi

# Test configuration without making it boot default
test:
	#!/usr/bin/env sh
	if [ "{{uname}}" = "Darwin" ]; then
		nix build "{{darwin_flake}}.system"
		sudo ./result/sw/bin/darwin-rebuild test --flake "$(pwd)#{{target_name}}"
	else
		sudo nixos-rebuild test --flake "{{nixos_flake}}"
	fi

# Build without switching
build:
	#!/usr/bin/env sh
	if [ "{{uname}}" = "Darwin" ]; then
		nix build "{{darwin_flake}}.system"
	else
		nix build "{{nixos_flake}}.config.system.build.toplevel"
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
	nix build '.#nixosConfigurations.work-wsl.config.system.build.toplevel' --json \
		| jq -r '.[].outputs | to_entries[].value' \
		| cachix push janicogabo-nixos-config

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
	sudo nix store gc --delete-older-than 30d

# Show disk usage
gc-stats:
	nix store gc --print-roots --print-live --print-dead

# Edit this justfile
edit:
	$EDITOR justfile

# Show detected system info
info:
	@echo "System: {{uname}}"
	@echo "Target: {{target_name}}"
	@echo "Flake dir: {{`pwd`}}"

# List all available targets
targets:
	@echo "System configs:"
	@echo "  macbook-pro-m1  (darwin)"
	@echo "  work-wsl        (nixos)"
	@echo ""
	@echo "Home-manager configs:"
	@echo "  janicolo@x86_64-linux      (standalone Linux)"
	@echo "  janicolo@x86_64-linux-wsl  (WSL)"
