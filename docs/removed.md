# Removed/Not Yet Migrated Items

This documents everything from the original `configuration.nix` and `home.nix` that was either removed or not yet migrated to the new flake-parts structure.

## Modules Not Imported in Host Composition

These modules exist but aren't currently imported in `AppleII.nix`:

### Development Languages
- `nixos.git` - Git configuration
- `nixos.neovim` - Neovim editor
- `nixos.lsp` - LSP servers
- `nixos.python` - Python + uv + pipenv + pyenv
- `nixos.nodejs` - Node.js
- `nixos.go` - Go toolchain
- `nixos.lua` - Lua + luarocks
- `nixos.zig` - Zig compiler
- `nixos.flutter` - Flutter SDK

### Apps
- `nixos.browsers` - Brave, Chrome
- `nixos.terminals` - Ghostty, kitty, alacritty
- `nixos.media` - Spotify, OBS, mpv
- `nixos.productivity` - Obsidian, Slack
- `nixos.gaming` - Steam
- `nixos.tmux` - Tmux terminal multiplexer

---

## Home-Manager Packages (from home.nix)

These packages were in `home.packages` but need to be added back:

### CLI Tools
- `fastfetch` - System info
- `fzf` - Fuzzy finder
- `gh` - GitHub CLI
- `nmap` - Network scanner
- `oh-my-posh` - Shell prompt
- `p7zip` - Archive tool
- `rink` - Unit calculator
- `ripgrep` - Fast grep
- `tree` - Directory tree
- `unrar` - RAR extractor
- `unzip` - ZIP extractor
- `wget` - Download tool
- `wireshark` - Network analyzer

### GUI Apps
- `adwaita-icon-theme` - GTK icons
- `ani-cli` - Anime CLI
- `brave` - Brave browser
- `claude-code` - Claude Code CLI
- `ghostty` - Terminal emulator
- `gimp` - Image editor
- `github-desktop` - GitHub GUI
- `gnome-themes-extra` - GTK themes
- `google-chrome` - Chrome browser
- `obsidian` - Note-taking
- `obs-studio` - Screen recording
- `slack` - Messaging
- `spotify` - Music
- `steam` - Gaming

### GTK/Theming
- `gsettings-desktop-schemas`
- `gtk3`
- `gtk4`

### Development
- `flutter` - Mobile SDK
- `lua` - Lua runtime
- `luarocks` - Lua package manager

### LSP Servers
- `lua-language-server` - Lua LSP
- `gopls` - Go LSP
- `golines` - Go formatter
- `goimports-reviser` - Go imports
- `ruff` - Python linter/formatter
- `ty` - (unknown)

---

## Home-Manager Symlinks (from home.nix)

All dotfile symlinks were disabled. These need to be re-added to `symlinks.nix`:

### Shell Config
- `.zshrc` -> `${dotfiles_path}/.zshrc`

### Terminal Configs
- `.config/alacritty/alacritty.toml`
- `.config/ghostty/config`

### Editor Config
- `.config/nvim` (recursive)

### Shell/Prompt
- `.config/oh-my-posh` (recursive)

### Tmux
- `.config/tmux` (recursive)
- `.config/tmux/plugins/catppuccin-tmux` (fetchFromGitHub)
- `.config/tmux/plugins/tmux-sensible` (fetchFromGitHub)
- `.config/tmux/plugins/tmux-yank` (fetchFromGitHub)
- `.config/tmux/plugins/tpm` (fetchFromGitHub)
- `.config/tmux/plugins/vim-tmux-navigator` (fetchFromGitHub)

### SSH
- `.ssh/config`
- `.ssh/rc`

### 1Password
- `.config/1Password/ssh/agent.toml`

### Nix
- `.config/nix/nix.conf`

### Misc
- `.stow-global-ignore`

### Desktop Environment
- `.config/anyrun` (recursive)
- `.config/waybar` (recursive)
- `.config/rofi/config.rasi`
- `.config/hypr` (recursive)

---

## Home-Manager Programs/Services (from home.nix)

These program/service configurations need to be migrated:

### Git Config
```nix
programs.git = {
  enable = true;
  settings = {
    user.name = "Chris Kim";
    user.email = "christopher.cuong.kim@gmail.com";
    core.editor = "nvim";
  };
};
```

### Tmux Config
```nix
programs.tmux = {
  enable = true;
  shell = "${pkgs.zsh}/bin/zsh";
  terminal = "tmux-256color";
};
```

### GTK
```nix
gtk.enable = true;
```

### Waybar
```nix
programs.waybar.enable = true;
```

### Kitty
```nix
programs.kitty.enable = true;
```

### Network Manager Applet
```nix
services.network-manager-applet.enable = true;
```

### Session Variables
```nix
home.sessionVariables = {
  NIXOS_OZONE_WL = "1";
  HYPRSHOT_DIR = "/home/chriskim/Pictures";
  GDK_BACKEND = "wayland";
};
```

---

## NixOS Settings (from configuration.nix)

### Auto-Upgrade (not migrated)
```nix
system.autoUpgrade.enable = true;
system.autoUpgrade.allowReboot = true;
```

### System Packages (in modules but not imported)
- `brightnessctl`
- `newt`
- `qimgv` - Image viewer
- `cheese` - Webcam app
- `v4l-utils` - Video4Linux tools

---

## How to Re-Add

### 1. Add modules to host composition

Edit `modules/hosts/AppleII.nix` and add to imports:
```nix
# Development
nixos.git
nixos.neovim
nixos.lsp
nixos.python
nixos.nodejs
nixos.go
nixos.lua
nixos.zig
nixos.flutter
nixos.tmux

# Apps
nixos.browsers
nixos.terminals
nixos.media
nixos.productivity
nixos.gaming
```

### 2. Re-enable symlinks

Edit `modules/features/dotfiles/symlinks.nix` and add home.file entries.

### 3. Add home-manager feature modules

Create home-manager modules for user-level config (git, tmux, gtk, etc.)
using the pattern documented in `docs/learnings.md`.
