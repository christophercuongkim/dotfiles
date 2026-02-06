# NixOS Architecture

This document describes the flake-parts dendritic architecture used in this NixOS configuration.

## Overview

The configuration uses [flake-parts](https://flake.parts/) with an "import tree" pattern where every `.nix` file in `modules/` is automatically imported as a flake-parts module. This creates a dendritic (tree-like) structure where each file contributes to the overall flake configuration.

## Directory Structure

```
modules/
├── flake-parts.nix          # Enables flake-parts.flakeModules.modules
├── meta.nix                 # Shared options (username, dotfilesPath)
├── systems.nix              # systems = ["x86_64-linux"]
│
├── outputs/
│   ├── nixos.nix            # configurations.nixos → flake.nixosConfigurations
│   ├── home-manager.nix     # Home-manager integration with topLevel@ pattern
│   ├── packages.nix         # Waybar overlay, anyrun packages
│   └── devshells.nix        # perSystem.devShells
│
├── hosts/
│   ├── AppleII.nix          # Host composition - imports feature modules
│   └── AppleII-hardware.nix # Hardware-specific configuration
│
└── features/                # One feature per file
    ├── core/                # nix, locale, boot, user
    ├── desktop/             # hyprland, waybar, rofi, etc.
    ├── networking/          # networkmanager, tailscale
    ├── audio/               # pipewire
    ├── bluetooth/           # blueman
    ├── security/            # 1password, polkit, pam
    ├── fingerprint/         # fprintd
    ├── printing/            # cups, avahi
    ├── virtualization/      # docker, virtualbox
    ├── fonts/               # fonts
    ├── shell/               # zsh, tmux, cli-tools
    ├── development/         # git, neovim, lsp, languages
    ├── apps/                # firefox, browsers, terminals, etc.
    ├── power/               # logind, power-profiles
    ├── hardware/            # framework-specific
    └── dotfiles/            # symlinks for config files
```

## Key Concepts

### 1. Every File is a Flake-Parts Module

Every `.nix` file under `modules/` receives flake-parts args and can contribute to the flake:

```nix
{ config, inputs, lib, ... }:
{
  # Contribute to flake.modules.nixos.*
  flake.modules.nixos.myfeature = { pkgs, ... }: {
    environment.systemPackages = [ pkgs.mypackage ];
  };
}
```

### 2. The `topLevel@` Pattern

When a NixOS module needs to access flake-parts config (like `flake.modules.homeManager.*`), use the `topLevel@` pattern:

```nix
topLevel@{ inputs, ... }:
{
  flake.modules.nixos.my-module =
    { config, ... }:  # This receives NixOS args
    {
      # Access flake-parts config via topLevel.config
      home-manager.users.myuser.imports = [
        topLevel.config.flake.modules.homeManager.core
      ];
    };
}
```

The outer function receives flake-parts args, the inner function receives NixOS module args.

### 3. Plain Attrsets vs Functions

**Plain attrsets** for simple, static config:
```nix
flake.modules.nixos.nix = {
  nix.settings.experimental-features = "nix-command flakes";
};
```

**Functions** when you need module args (`config`, `pkgs`, `lib`):
```nix
flake.modules.nixos.zsh = { pkgs, ... }: {
  users.users.myuser.shell = pkgs.zsh;
};
```

### 4. Host Composition

Hosts are defined in `modules/hosts/` and compose features by importing modules:

```nix
# modules/hosts/AppleII.nix
{ config, inputs, ... }:
let
  inherit (config.flake.modules) nixos;
in
{
  configurations.nixos.AppleII.module = {
    imports = [
      nixos.nix
      nixos.locale
      nixos.hyprland
      nixos.zsh
      # ... more features
    ];
  };
}
```

### 5. Home-Manager Integration

Home-manager modules are defined as `flake.modules.homeManager.*` and imported via the NixOS home-manager module:

```nix
# In a feature module (e.g., git.nix)
{
  flake.modules.nixos.git = { pkgs, ... }: {
    environment.systemPackages = [ pkgs.git ];
  };

  flake.modules.homeManager.git = {
    programs.git = {
      enable = true;
      settings.user.name = "My Name";
    };
  };
}
```

```nix
# In home-manager.nix
users.${username}.imports = [
  topLevel.config.flake.modules.homeManager.core
  topLevel.config.flake.modules.homeManager.git
  # ...
];
```

### 6. Dotfiles Symlinks

Config files are symlinked via home-manager in `modules/features/dotfiles/symlinks.nix`:

```nix
flake.modules.homeManager.symlinks = { dotfilesPath, ... }: {
  home.file = {
    ".config/nvim".source = "${dotfilesPath}/.config/nvim";
    ".zshrc".source = "${dotfilesPath}/.zshrc";
  };
};
```

The `dotfilesPath` is passed via `extraSpecialArgs` in home-manager.nix.

## Module Flow

```
flake.nix
    │
    ├── imports = [ ./modules ];  # import-tree loads all .nix files
    │
    └── modules/
        │
        ├── flake-parts.nix      # enables module system
        ├── meta.nix             # defines username, dotfilesPath options
        ├── systems.nix          # defines target systems
        │
        ├── outputs/
        │   ├── nixos.nix        # maps configurations.nixos → nixosConfigurations
        │   └── home-manager.nix # wires up home-manager with modules
        │
        ├── hosts/
        │   └── AppleII.nix      # composes features into a host
        │
        └── features/**/*.nix    # each defines flake.modules.nixos.* and/or
                                 # flake.modules.homeManager.*
```

## Commands

```bash
# Build and switch
sudo nixos-rebuild switch --flake .#AppleII

# Build without switching (test)
nix build .#nixosConfigurations.AppleII.config.system.build.toplevel

# Check flake outputs
nix flake show

# Check for evaluation errors
nix eval .#nixosConfigurations.AppleII.config.system.build.toplevel --show-trace
```

## Common Patterns

### Adding a New System Package

```nix
# modules/features/apps/myapp.nix
{ ... }:
{
  flake.modules.nixos.myapp = { pkgs, ... }: {
    environment.systemPackages = [ pkgs.myapp ];
  };
}
```

Then add to host: `nixos.myapp` in `modules/hosts/AppleII.nix`.

### Adding Home-Manager Config

```nix
# modules/features/apps/myapp.nix
{ ... }:
{
  flake.modules.nixos.myapp = { pkgs, ... }: {
    environment.systemPackages = [ pkgs.myapp ];
  };

  flake.modules.homeManager.myapp = {
    programs.myapp.enable = true;
  };
}
```

Then add `topLevel.config.flake.modules.homeManager.myapp` to imports in `home-manager.nix`.

### Adding a Symlinked Config

Add to `modules/features/dotfiles/symlinks.nix`:

```nix
".config/myapp".source = "${dotfilesPath}/.config/myapp";
```

## Known Gotchas

1. **Use `homeManager` not `home`** - The module class is `homeManager` (capital M)

2. **Don't use `inputs.self` at eval time** - Causes infinite recursion. Pass paths via `extraSpecialArgs`

3. **Avoid conflicts with programs.\*.enable** - If using `programs.tmux.enable`, don't also symlink `.config/tmux`

4. **Module merging** - Plain attrsets merge; functions don't merge the same way

5. **stateVersion** - `home.stateVersion` must match or be compatible with `system.stateVersion`
