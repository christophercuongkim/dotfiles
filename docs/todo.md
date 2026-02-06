# Remaining Work

## Immediate (Build Verification)

- [ ] Wait for VirtualBox to finish compiling (~20-30 min)
- [ ] Verify build completes successfully
- [ ] Test `sudo nixos-rebuild switch --flake .#AppleII`
- [ ] Verify system boots and works correctly

## Short-Term (Home-Manager Features)

Currently all packages are installed at system level. To get proper home-manager integration:

- [ ] Re-enable `features/dotfiles/symlinks.nix` for config file symlinks
- [ ] Add home-manager modules for programs that benefit from user-level config:
  - [ ] `flake.modules.homeManager.git` - Git user config
  - [ ] `flake.modules.homeManager.zsh` - Zsh user config, aliases
  - [ ] `flake.modules.homeManager.tmux` - Tmux user config
  - [ ] `flake.modules.homeManager.gtk` - GTK theming
  - [ ] `flake.modules.homeManager.xdg` - XDG directories

### Pattern for Adding Home-Manager Features

```nix
# In features/shell/zsh.nix
topLevel@{ ... }:
{
  # System-level
  flake.modules.nixos.zsh = { pkgs, ... }: {
    programs.zsh.enable = true;
    users.users.${topLevel.config.username}.shell = pkgs.zsh;
  };

  # User-level (add to homeManager.core or create separate module)
  flake.modules.homeManager.zsh = {
    programs.zsh = {
      enable = true;
      autosuggestion.enable = true;
      syntaxHighlighting.enable = true;
    };
  };
}
```

Then update `home-manager.nix` to import the new module:
```nix
users.${username}.imports = [
  topLevel.config.flake.modules.homeManager.core
  topLevel.config.flake.modules.homeManager.zsh
  # ... other modules
];
```

## Medium-Term (Polish)

- [ ] Add missing apps to host composition:
  - [ ] `nixos.browsers` (Brave, Chrome)
  - [ ] `nixos.terminals` (Ghostty, kitty, alacritty)
  - [ ] `nixos.media` (Spotify, OBS, mpv)
  - [ ] `nixos.productivity` (Obsidian, Slack)
  - [ ] `nixos.gaming` (Steam)
  - [ ] `nixos.tmux`
  - [ ] Development languages (git, neovim, lsp, python, nodejs, go, lua, zig, flutter)

- [ ] Remove old configuration files:
  - [ ] `nixos/hosts/AppleII/configuration.nix`
  - [ ] `nixos/hosts/AppleII/hardware-configuration.nix`
  - [ ] `nixos/modules/home-manager/home.nix`

- [ ] Add devshell for the dotfiles repo itself

## Long-Term (Enhancements)

- [ ] Add second host configuration (e.g., server, VM)
- [ ] Add agenix for secrets management
- [ ] Add CI/CD for flake checks
- [ ] Add custom packages output
- [ ] Consider standalone home-manager for non-NixOS machines

## Optional Improvements

- [ ] Use `lib.mkDefault` for values that should be overridable per-host
- [ ] Add `flake.modules.nixos.host_AppleII` for host-specific overrides
- [ ] Create `flake.modules.nixos.desktop` bundle that imports common desktop modules
- [ ] Add treefmt-nix for consistent formatting
