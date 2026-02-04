# Dotfiles Improvement Suggestions

## 1. Documentation

### Add Comprehensive README
The current README is minimal (5 lines). Consider adding:
- Installation instructions for new machines
- Architecture overview explaining the NixOS + Home Manager + Stow approach
- Hardware compatibility notes (Framework 13 specifics)
- Quick reference for common commands (`nixos-rebuild switch`, etc.)

### Add Setup Guide
Create a `SETUP.md` with step-by-step instructions for bootstrapping a new machine from scratch.

---

## 2. NixOS Module Structure

### Split `configuration.nix` (394 lines)
The main config is getting large. Consider modularizing into:
```
nixos/modules/
├── desktop/
│   └── hyprland.nix
├── services/
│   ├── network.nix
│   └── printing.nix
├── security/
│   └── fingerprint.nix
└── dev/
    └── virtualization.nix
```

### Modularize Home Manager
Extract program-specific configs:
```
nixos/modules/home-manager/
├── programs/
│   ├── nvim.nix
│   └── tmux.nix
└── shell/
    └── zsh.nix
```

---

## 3. Cleanup & Consolidation

### Remove Dead Code
- `anyrun/` config exists but is commented out in home.nix (now using rofi)
- `nvim/lua/backup-init.lua` - remove if no longer needed
- `.config/rofi/config.ron.old` - remove backup file

### Add to `.gitignore`
- `file_structure.txt` (auto-generated)

### Commit Pending Changes
3 files currently modified:
- `.config/hypr/hyprland.conf`
- `nixos/hosts/AppleII/configuration.nix`
- `nixos/modules/home-manager/home.nix`

---

## 4. Missing Configurations

### XDG Portal Setup
Add xdg-desktop-portal configuration for better Wayland app integration (screen sharing, file dialogs).

### SSH Config
Consider adding a templated `~/.ssh/config` for common hosts (managed via home.nix or stow).

### Git Aliases
Add useful git aliases to the git configuration in home.nix:
```nix
programs.git = {
  aliases = {
    st = "status";
    co = "checkout";
    br = "branch";
    lg = "log --oneline --graph --decorate";
  };
};
```

### Shell Aliases
Document or centralize shell aliases in `.zshrc` or a separate sourced file.

---

## 5. Security Hardening

### Firewall Configuration
The firewall section in configuration.nix is commented out. Consider enabling with sensible defaults:
```nix
networking.firewall = {
  enable = true;
  allowedTCPPorts = [ ];
  allowedUDPPorts = [ ];
};
```

### Secrets Management
Document how secrets (API keys, tokens) are handled. Consider:
- `sops-nix` for encrypted secrets in the repo
- Or document the 1Password workflow for credentials

---

## 6. Developer Experience

### Add Helper Scripts
Create a `scripts/` directory with common operations:
- `rebuild.sh` - wrapper for `sudo nixos-rebuild switch --flake .#AppleII`
- `update.sh` - update flake inputs and rebuild
- `cleanup.sh` - garbage collection for nix store

### Neovim LSP Documentation
Document which language servers are configured and how to add new ones.

### Tmux Session Templates
Add tmuxinator or custom session configs for common project setups.

---

## 7. Multi-Host Support

### Prepare for Multiple Machines
If planning to use on other hardware, structure hosts more flexibly:
```
nixos/hosts/
├── common/
│   └── default.nix  # shared config
├── AppleII/
│   └── configuration.nix
└── future-desktop/
    └── configuration.nix
```

---

## 8. Aesthetics & Theming

### Centralize Theme Variables
Create a shared theme file for consistent colors across:
- Hyprland (borders, gaps)
- Waybar
- Rofi
- Terminal (alacritty/ghostty)

Currently using: Tokyo Night (nvim), Catppuccin Mocha (tmux)

### Document Font Setup
Note the Nerd Font requirements (JetBrains Mono) for icons to display correctly.

---

## 9. Automation

### Automatic Updates
Consider adding a systemd timer for periodic `nix flake update` notifications.

### Pre-commit Hooks
Add formatting checks for Nix files using `nixfmt` or `alejandra`.

---

## 10. Performance & Power

### Power Management
Document or add TLP/auto-cpufreq configuration for laptop battery optimization.

### Framework-Specific Tweaks
The Framework 13 AMD has specific optimizations available - document any applied settings.

---

## Priority Order

1. **High**: Commit pending changes, cleanup dead configs
2. **High**: Add comprehensive README
3. **Medium**: Modularize NixOS configuration
4. **Medium**: Add helper scripts
5. **Low**: Multi-host support preparation
6. **Low**: Theme centralization
