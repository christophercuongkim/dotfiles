# Documentation Index

Migration from monolithic NixOS config to flake-parts dendritic pattern.

## Files

| File | Purpose |
|------|---------|
| [session-context.md](./session-context.md) | **Start here** - Current state, debugging history, next steps |
| [learnings.md](./learnings.md) | Key patterns and common pitfalls |
| [progress.md](./progress.md) | What's been completed |
| [todo.md](./todo.md) | Remaining work |
| [removed.md](./removed.md) | Items not yet migrated from original config |

## Quick Start for New Session

1. Read `session-context.md` for current state
2. Check if build completed: `nix build .#nixosConfigurations.AppleII.config.system.build.toplevel`
3. Follow "Next Steps" in session-context.md

## Original Files (to be deleted after verification)

- `nixos/hosts/AppleII/configuration.nix` - Original monolithic config
- `nixos/hosts/AppleII/hardware-configuration.nix` - Moved to modules/hosts/
- `nixos/modules/home-manager/home.nix` - Original home-manager config

## Reference Repos

- `/home/chriskim/repos/docs/nix-config` - gaetanlepage's clean implementation
- `/home/chriskim/repos/docs/infra` - mightyiam's implementation
- `/home/chriskim/repos/docs/dendritic` - Dendritic pattern docs
