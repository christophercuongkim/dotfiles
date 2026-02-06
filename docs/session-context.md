# Session Context for Continuation

## Workflow Pattern

**Build Testing Workflow:**
1. Ask user to run build command with output redirected to `build_output.txt`
2. User reports when complete or if it hangs
3. Read `build_output.txt` to diagnose any errors
4. Don't run builds directly - user controls when builds run

Example prompt:
> Please run: `sudo nixos-rebuild switch --flake .#AppleII --show-trace 2>&1 | tee build_output.txt`
> Let me know when it completes or hangs, and I'll check build_output.txt

---

## Current State (as of last session)

**Build Status:** Compiling VirtualBox from source (expected 20-30 min)
- Home-manager integration is working
- All NixOS modules load correctly
- No evaluation errors

**What's Working:**
- Flake-parts infrastructure with import-tree
- `configurations.nixos` option mapping to `flake.nixosConfigurations`
- Home-manager integration using `topLevel@` pattern
- All feature modules loading via `flake.modules.nixos.*`

**What's Not Yet Working:**
- Dotfiles symlinks (disabled in `symlinks.nix`)
- Home-manager feature contributions (only base/core settings active)
- Many apps not imported in host composition

---

## Key Debugging Journey

### Problem 1: Class Mismatch Error
```
error: A 'home' module (flake.modules.home.zsh...) was imported into a module set of class 'homeManager'
```
**Cause:** Using `flake.modules.home.*`
**Fix:** Use `flake.modules.homeManager.*` (capital M)

### Problem 2: Build Hanging on Home-Manager
**Symptoms:** Build hangs indefinitely on `home-manager-chriskim.service.drv`
**Cause:** Plain attrset for homeManager modules instead of proper function
**Fix:** Two approaches that work:

1. **mightyiam pattern** - Function that takes args:
   ```nix
   flake.modules.homeManager.base = args: { ... };
   ```

2. **gaetanlepage pattern** (current) - Use `topLevel@` to separate contexts:
   ```nix
   topLevel@{ inputs, ... }:
   {
     flake.modules.homeManager.core = { ... };  # plain attrset OK here

     flake.modules.nixos.home-manager =
       { config, ... }:  # NixOS module function
       {
         home-manager.users.${username}.imports = [
           topLevel.config.flake.modules.homeManager.core  # reference via topLevel
         ];
       };
   }
   ```

### Problem 3: Circular Dependency with inputs.self
**Cause:** Using `inputs.self` at flake-parts evaluation time in symlinks
**Fix:** Either hardcode path or pass via `extraSpecialArgs`

### Problem 4: Config File Conflicts
```
Existing file '/home/user/.config/tmux/tmux.conf' is in the way of '/nix/store/...'
```
**Cause:** Both `programs.tmux.enable` and `home.file.".config/tmux"` managing same files
**Fix:** Choose one approach - either program module OR manual symlinks

---

## Reference Implementations

### 1. gaetanlepage/nix-config (RECOMMENDED)
Location: `/home/chriskim/repos/docs/nix-config`

**Key patterns:**
- Separate `modules/nixos/` and `modules/home/` directories
- Custom `nixosHosts` and `homeHosts` options in `modules/flake/hosts.nix`
- `topLevel@` pattern for home-manager integration
- `flake.modules.nixos.core.imports = [...]` for module composition

**Key files:**
- `modules/flake/hosts.nix` - Host option definitions
- `modules/nixos/dev/home-manager/default.nix` - Home-manager NixOS integration
- `modules/home/core/default.nix` - Home-manager core module

### 2. mightyiam/infra
Location: `/home/chriskim/repos/docs/infra`

**Key patterns:**
- `flake.modules.homeManager.base = args: { ... }` (function form)
- Nested attribute contributions: `flake.modules.homeManager.base.programs.fish.enable = true`

**Key files:**
- `modules/home-manager/base.nix`
- `modules/home-manager/nixos.nix`

### 3. Dendritic docs
Location: `/home/chriskim/repos/docs/dendritic`

**Key concept:** Every file is a flake-parts module with same interface

---

## File Purposes Quick Reference

```
modules/
├── flake-parts.nix      # imports flake-parts.flakeModules.modules
├── meta.nix             # options: username, dotfilesPath
├── systems.nix          # systems = ["x86_64-linux"]
│
├── outputs/
│   ├── nixos.nix        # configurations.nixos option → flake.nixosConfigurations
│   ├── home-manager.nix # homeManager.core + nixos.home-manager wiring
│   ├── packages.nix     # waybar overlay, anyrun packages
│   └── devshells.nix    # perSystem.devShells
│
├── hosts/
│   ├── AppleII.nix      # Host composition - imports feature modules
│   └── AppleII-hardware.nix
│
└── features/            # One feature per file
    ├── core/            # nix, locale, boot, user
    ├── desktop/         # hyprland, waybar, etc.
    ├── networking/      # networkmanager, tailscale
    ├── audio/           # pipewire
    ├── bluetooth/       # blueman
    ├── security/        # 1password, polkit, pam
    ├── fingerprint/     # fprintd
    ├── printing/        # cups, avahi
    ├── virtualization/  # docker, virtualbox
    ├── fonts/           # fonts
    ├── shell/           # zsh, tmux, cli-tools
    ├── development/     # git, neovim, lsp, languages
    ├── apps/            # firefox, browsers, terminals, etc.
    ├── power/           # logind, power-profiles
    ├── hardware/        # framework-specific
    └── dotfiles/        # symlinks (currently disabled)
```

---

## Next Steps (in order)

### Step 1: Test the Build

**IMPORTANT:** Ask the user to run the build and monitor `build_output.txt`:

```
Please run the build in a separate terminal:

sudo nixos-rebuild switch --flake .#AppleII --show-trace 2>&1 | tee build_output.txt

Let me know when it completes or if it hangs, and I'll check build_output.txt for errors.
```

The user prefers to control builds themselves and report back. Don't run builds directly - ask them to run and update `build_output.txt`, then read that file to diagnose issues.

3. **If successful, add missing modules to host:**
   Edit `modules/hosts/AppleII.nix` and add:
   ```nix
   nixos.git
   nixos.neovim
   nixos.lsp
   nixos.python
   nixos.nodejs
   nixos.go
   # ... etc
   ```

4. **Re-enable symlinks:**
   Edit `modules/features/dotfiles/symlinks.nix` - see `docs/removed.md` for full list

5. **Add home-manager features:**
   Use the `topLevel@` pattern to add `flake.modules.homeManager.*` contributions

6. **Clean up old files:**
   ```bash
   rm -rf nixos/
   ```

---

## Commands Reference

```bash
# Build and switch (preferred - with output capture)
sudo nixos-rebuild switch --flake .#AppleII --show-trace 2>&1 | tee build_output.txt

# Build without switching (test only)
nix build .#nixosConfigurations.AppleII.config.system.build.toplevel

# Check flake outputs
nix flake show

# Check for evaluation errors
nix eval .#nixosConfigurations.AppleII.config.system.build.toplevel --show-trace
```

---

## Known Issues / Gotchas

1. **VirtualBox compiles from source** - Takes 20-30 min, can temporarily disable in host

2. **Symlinks need careful handling** - Can't use `inputs.self` directly in home.file, need to pass path via extraSpecialArgs or hardcode

3. **programs.X.enable conflicts with home.file** - If a program module manages a config file, don't also symlink it

4. **Module merging** - Multiple files can contribute to same `flake.modules.nixos.X` if they're plain attrsets (they merge). Functions don't merge the same way.

5. **home.stateVersion** - Must match or be compatible with system stateVersion
