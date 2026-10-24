# Personal dotfiles

These are my personal dotfiles designed for the Nix package manager and NixOS.

## Structure

```
dotfiles/
├── flake.nix              # Main flake entry point
├── flake.lock
├── justfile               # Cross-platform build commands
├── lib/
│   ├── mksystem.nix       # Builds nixosConfigurations / darwinConfigurations
│   └── mkhome.nix         # Builds homeConfigurations (standalone)
├── machines/
│   ├── darwin-shared.nix  # Shared Darwin system config
│   ├── macbook-pro-m1.nix # MacBook Pro M1 system config
│   └── work-wsl.nix       # NixOS WSL system config
├── users/
│   └── janicolo/
│       ├── darwin.nix     # User-level Darwin config (homebrew, user)
│       ├── home-manager.nix # All home-manager config (with isStandalone support)
│       ├── hm-standalone.nix # (generated, not used)
│       ├── ghostty/       # Ghostty terminal config
│       ├── nvim/          # Neovim config (lua modules)
│       │   ├── init.lua
│       │   └── lua/
│       ├── wezterm/       # WezTerm terminal config
│       ├── zed/           # Zed editor config
│       └── nix/           # Nix config
└── README.md
```

## Quick Start

### macOS (nix-darwin)
```bash
# Build and switch
just switch

# Or with explicit target
just switch target=macbook-pro-m1
```

### NixOS WSL
```bash
# Build and switch (requires sudo)
just switch target=work-wsl
```

### Standalone Home-Manager (AlmaLinux, Fedora, etc.)
```bash
# After installing Nix on target system
git clone <this-repo> ~/dotfiles && cd ~/dotfiles

# Build and apply user config only
just hm-switch

# For WSL (Ubuntu/AlmaLinux in WSL)
just hm-switch-wsl
```

## Available Targets

```bash
just targets
```

Output:
```
System configs:
  macbook-pro-m1  (darwin)
  work-wsl        (nixos)

Home-manager configs:
  janicolo@x86_64-linux      (standalone Linux)
  janicolo@x86_64-linux-wsl  (WSL)
```

## Common Commands

```bash
# System (macOS/WSL)
just switch           # Build and activate
just build            # Build only
just test             # Test without making default
just rollback         # Rollback to previous generation

# Home-manager (Linux)
just hm-switch        # Standalone Linux
just hm-switch-wsl    # WSL-specific
just hm-test          # Dry run
just hm-build         # Build only
just hm-rollback      # Rollback

# Maintenance
just check            # Validate flake
just check-all        # Validate all outputs
just update           # Update flake inputs
just gc               # Garbage collect (30 days)
just gc-stats         # Show store stats
just gen              # List generations

# Info
just info             # Show detected system/target
just targets          # List all targets
```

## Configuration Details

### Neovim
- Entry: `users/janicolo/nvim/init.lua`
- Uses `vim.fn.stdpath("config")` for relative package.path
- Modules: `lua/settings.lua`, `lua/lsp.lua`, `lua/notes.lua`

### Key Features
- **Relative paths** - `vim.fn.stdpath("config")` resolves correctly in nix store
- **isStandalone flag** - Same `home-manager.nix` works for NixOS, nix-darwin, and standalone
- **Platform detection** - `isDarwin`/`isLinux`/`isWSL` conditionals in home-manager
- **Shared user config** - All user config in `users/janicolo/`

## Adding New Machines

1. Create `machines/<name>.nix`
2. Add to `flake.nix`:
   ```nix
   darwinConfigurations.<name> = mkSystem "<name>" { system = "aarch64-darwin"; user = "janicolo"; darwin = true; };
   # or
   nixosConfigurations.<name> = mkSystem "<name>" { system = "x86_64-linux"; user = "janicolo"; wsl = true; };
   ```
3. Add home-manager if needed:
   ```nix
   homeConfigurations."janicolo@x86_64-linux-<name>" = mkHome "<name>" { system = "x86_64-linux"; user = "janicolo"; isWSL = true; };
   ```

## Requirements

- Nix with flakes enabled (`experimental-features = nix-command flakes`)
- `just` command runner (`nix run nixpkgs#just` or install via package manager)

## Notes

- `result/` symlink created by `nix build` - safe to delete, recreated on next build
- `nix store gc --delete-older-than 30d` for garbage collection
- Home-manager config uses `isStandalone` flag to work with/without NixOS
