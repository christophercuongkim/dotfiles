# Nix Configuration

User-level nix daemon configuration. Settings here apply system-wide via `/etc/nix/nix.conf` (or are merged with it by NixOS).

---

## Quick Start

**Add a new nix setting:**
1. Edit `.config/nix/nix.conf` directly
2. Run `sudo nixos-rebuild switch --flake .#AppleII` from the dotfiles root

**Change an existing option:**
Edit the relevant line in `nix.conf` and rebuild.

**Apply changes:**
```sh
cd ~/dotfiles
sudo nixos-rebuild switch --flake .#AppleII
```

---

## Structure

```
.config/nix/
├── README.md     # This file
└── nix.conf      # Nix daemon configuration options
```

`nix.conf` — low-level nix settings that control daemon behavior, feature flags, and binary cache configuration. Corresponds to options in `man nix.conf`.

---

## Key Settings

| Option | Value | Purpose |
|--------|-------|---------|
| `experimental-features` | `nix-command flakes` | Enables the `nix` CLI subcommands (`nix build`, `nix run`, etc.) and flake support required by this repo |

---

## Apply Changes

From the dotfiles root:

```sh
sudo nixos-rebuild switch --flake .#AppleII
```

The main flake is at `/home/chriskim/dotfiles/flake.nix`. NixOS reads this directory as part of the system configuration; changes to `nix.conf` take effect after the next rebuild.
