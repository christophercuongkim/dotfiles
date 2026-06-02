# 1Password Config

## Quick Start

This directory configures the 1Password SSH agent. To apply changes after editing:

1. Restart 1Password: quit and relaunch the app (or `pkill 1password && 1password &`)
2. Verify the agent: `SSH_AUTH_SOCK=~/.1password/agent.sock ssh-add -l`

No NixOS rebuild is needed — 1Password reads this file directly at runtime.

## Structure

```
.config/1Password/
└── ssh/
    └── agent.toml   # SSH agent configuration (key sources and ordering)
```

`agent.toml` is symlinked from `~/.config/1Password/ssh/agent.toml` via home-manager.

## Key Settings

**`ssh/agent.toml`** — controls which vaults the SSH agent exposes keys from, and in what order they are offered to SSH servers.

Currently enabled vaults (in order):
1. `Private` — personal SSH keys
2. `Personal Dev` — dev-related SSH keys

Key ordering matters: the agent tries keys from each `[[ssh-keys]]` block top-to-bottom. Put the vault you use most often first.

## Apply Changes

| Change | How to apply |
|--------|-------------|
| Edit `agent.toml` | Restart 1Password |
| Add a new vault | Add an `[[ssh-keys]]` block, restart 1Password |
| home-manager symlink broken | Run `sudo nixos-rebuild switch --flake .#AppleII` |

To add a key from a specific item rather than an entire vault:

```toml
[[ssh-keys]]
item = "My SSH Key"
vault = "My Custom Vault"
```

Full docs: https://developer.1password.com/docs/ssh/agent/config
