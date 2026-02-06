# Flake-Parts Dendritic Pattern - Learnings

## Key Patterns

### 1. Every File is a Flake-Parts Module

Every `.nix` file under `modules/` receives flake-parts args:
```nix
{ config, inputs, lib, ... }:
{
  # module content
}
```

### 2. Use `topLevel@` for NixOS Modules That Need Flake-Parts Context

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

**Why?** The outer function receives flake-parts args, the inner function receives NixOS module args. They're different evaluation contexts.

### 3. Plain Attrsets vs Functions for `flake.modules.*`

- **Plain attrsets** for simple, static config:
  ```nix
  flake.modules.nixos.nix = {
    nix.settings.experimental-features = "nix-command flakes";
  };
  ```

- **Functions** when you need module args (`config`, `pkgs`, `lib`):
  ```nix
  flake.modules.nixos.zsh = { pkgs, ... }: {
    users.users.myuser.shell = pkgs.zsh;
  };
  ```

- **Functions** for homeManager modules that need home-manager args:
  ```nix
  flake.modules.homeManager.core = { lib, pkgs, config, ... }: {
    home.homeDirectory = "/home/${config.home.username}";
  };
  ```

### 4. Module Composition via `.imports`

Use nested `.imports` attribute to compose modules:
```nix
{ config, ... }:
{
  flake.modules.nixos.core.imports = with config.flake.modules.nixos; [
    nix
    locale
    boot
    user
  ];
}
```

### 5. Host-Specific Modules Convention

Use `host_${hostname}` naming for host-specific overrides:
```nix
flake.modules.nixos.host_AppleII.imports = [ ... ];
flake.modules.homeManager.host_AppleII = { ... };
```

## Common Pitfalls

### 1. Class Mismatch Error

**Error:** `A 'home' module was imported into a module set of class 'homeManager'`

**Cause:** Using `flake.modules.home.*` instead of `flake.modules.homeManager.*`

**Fix:** Always use `homeManager` (capital M) for home-manager modules.

### 2. Circular Dependencies with `inputs.self`

**Problem:** Using `inputs.self` at flake-parts evaluation time can cause infinite recursion.

**Fix:** Pass paths via `extraSpecialArgs` or use hardcoded paths:
```nix
home-manager.extraSpecialArgs = {
  dotfilesPath = /home/user/dotfiles;
};
```

### 3. Duplicate Option Definitions

**Error:** `The option 'X' is defined multiple times`

**Fix:** Only define options in one place. Use `lib.mkDefault` for defaults that can be overridden.

### 4. Config File Conflicts with Home-Manager

**Error:** `Existing file 'X' is in the way of 'Y'`

**Cause:** Both `programs.X.enable` and `home.file."X"` trying to manage the same file.

**Fix:** Choose one approach - either use the program module OR manual symlinks, not both.

## Reference Implementations

1. **gaetanlepage/nix-config** - Clean separation of nixos/home modules
   - Uses `topLevel@` pattern for home-manager integration
   - Custom `nixosHosts` option for host definitions

2. **mightyiam/infra** - Uses `flake.modules.homeManager.base` pattern
   - homeManager modules are functions: `args: { ... }`

## File Structure Convention

```
modules/
├── flake-parts.nix          # Enable flake-parts.flakeModules.modules
├── meta.nix                 # Shared options (username, dotfilesPath)
├── systems.nix              # systems = ["x86_64-linux"]
├── outputs/
│   ├── nixos.nix            # configurations.nixos → flake.nixosConfigurations
│   ├── home-manager.nix     # Home-manager integration
│   └── ...
├── hosts/
│   └── MyHost.nix           # Host composition
└── features/
    ├── core/                # nix, locale, boot, user
    ├── desktop/             # hyprland, waybar, etc.
    └── ...                  # One feature per file
```
