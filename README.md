# Dotfiles

NixOS configuration using flake-parts dendritic pattern for a Framework AMD AI 300-series laptop.

## Quick Start

```bash
# Clone the repo
git clone https://github.com/yourusername/dotfiles.git ~/dotfiles
cd ~/dotfiles

# Build and switch (first time may take a while)
sudo nixos-rebuild switch --flake .#AppleII
```

## Architecture

See [docs/nix_architecture.md](docs/nix_architecture.md) for detailed architecture documentation.

```
modules/
├── outputs/          # Flake outputs (nixos, home-manager, packages)
├── hosts/            # Host compositions (AppleII)
└── features/         # Modular features (one per file)
    ├── core/         # nix, locale, boot, user
    ├── desktop/      # hyprland, waybar, rofi
    ├── shell/        # zsh, tmux, cli-tools
    ├── development/  # git, neovim, languages
    ├── apps/         # browsers, terminals, media
    └── ...
```

## Installed Packages

### Desktop Environment

| Package | Description |
|---------|-------------|
| hyprland | Wayland compositor |
| waybar | Status bar |
| rofi | Application launcher |
| anyrun | Application launcher |
| hyprlock | Lock screen |
| hypridle | Idle daemon |
| hyprpaper | Wallpaper manager |
| hyprshot | Screenshot tool |
| xdg-desktop-portal-hyprland | Portal for Hyprland |

### Terminals & Shell

| Package | Description |
|---------|-------------|
| ghostty | Terminal emulator |
| kitty | Terminal emulator |
| zsh | Shell |
| tmux | Terminal multiplexer |
| oh-my-posh | Prompt theme engine |
| fzf | Fuzzy finder |
| ripgrep | Fast grep |
| zoxide | Smart cd |
| tree | Directory tree |

### Development

| Package | Description |
|---------|-------------|
| neovim | Text editor |
| git | Version control |
| gh | GitHub CLI |
| github-desktop | GitHub GUI |
| nodejs | JavaScript runtime |
| python3 | Python runtime |
| go | Go language |
| lua | Lua language |
| zig | Zig language |
| flutter | Mobile SDK |
| pipenv | Python env manager |
| pyenv | Python version manager |
| uv | Fast Python package installer |

### LSP Servers

| Package | Description |
|---------|-------------|
| lua-language-server | Lua LSP |
| gopls | Go LSP |
| ruff | Python linter/formatter |
| golines | Go formatter |
| goimports-reviser | Go imports |

### Browsers

| Package | Description |
|---------|-------------|
| firefox | Web browser |
| brave | Web browser |
| google-chrome | Web browser |

### Apps

| Package | Description |
|---------|-------------|
| obsidian | Note-taking |
| slack | Messaging |
| spotify | Music |
| obs-studio | Screen recording |
| gimp | Image editor |
| steam | Gaming |
| dolphin | File manager |
| claude-code | AI assistant CLI |

### Networking & Security

| Package | Description |
|---------|-------------|
| protonvpn-gui | VPN client |
| nmap | Network scanner |
| wireshark | Network analyzer |
| tailscale | VPN mesh |
| 1password | Password manager |

### System

| Package | Description |
|---------|-------------|
| pipewire | Audio server |
| blueman | Bluetooth manager |
| brightnessctl | Brightness control |
| pavucontrol | Audio control |
| playerctl | Media control |

### Fonts

- JetBrains Mono (Nerd Font)
- Noto Fonts
- Noto CJK
- Noto Color Emoji

## Adding New Features

### 1. Add a New Package

Create a new file in the appropriate category:

```nix
# modules/features/apps/myapp.nix
{ ... }:
{
  flake.modules.nixos.myapp = { pkgs, ... }: {
    environment.systemPackages = [ pkgs.myapp ];
  };
}
```

Add to host composition in `modules/hosts/AppleII.nix`:

```nix
imports = [
  # ...existing imports...
  nixos.myapp
];
```

### 2. Add Home-Manager Config

For user-level configuration:

```nix
# modules/features/apps/myapp.nix
{ ... }:
{
  flake.modules.nixos.myapp = { pkgs, ... }: {
    environment.systemPackages = [ pkgs.myapp ];
  };

  flake.modules.homeManager.myapp = {
    programs.myapp = {
      enable = true;
      # config options...
    };
  };
}
```

Add to home-manager imports in `modules/outputs/home-manager.nix`:

```nix
users.${username}.imports = [
  # ...existing imports...
  topLevel.config.flake.modules.homeManager.myapp
];
```

### 3. Add Dotfile Symlink

For config files managed in this repo:

1. Add your config to `.config/myapp/` in the repo root
2. Add symlink in `modules/features/dotfiles/symlinks.nix`:

```nix
".config/myapp".source = "${dotfilesPath}/.config/myapp";
```

### 4. Add a New Feature Category

1. Create directory: `modules/features/mycategory/`
2. Create feature file: `modules/features/mycategory/myfeature.nix`
3. Follow the pattern above

## Commands

```bash
# Build and switch
sudo nixos-rebuild switch --flake .#AppleII

# Build without switching (test)
nix build .#nixosConfigurations.AppleII.config.system.build.toplevel

# Check flake outputs
nix flake show

# Update flake inputs
nix flake update
```

## Config Files

Dotfiles are symlinked from this repo to `~/.config/`:

- `nvim/` - Neovim configuration
- `hypr/` - Hyprland configuration
- `waybar/` - Waybar configuration
- `tmux/` - Tmux configuration
- `ghostty/` - Ghostty configuration
- `rofi/` - Rofi configuration
- `oh-my-posh/` - Shell prompt themes

## Documentation

- [nix_architecture.md](docs/nix_architecture.md) - Architecture details
- [learnings.md](docs/learnings.md) - Patterns and pitfalls
- [session-context.md](docs/session-context.md) - Migration notes
