# oh-my-posh

Custom prompt theme for oh-my-posh, loaded by zsh via `.zshrc`.

---

## Quick Start

**Change which theme file is loaded** — edit `.zshrc` line 41:
```zsh
eval "$(oh-my-posh init zsh --config $HOME/.config/oh-my-posh/zen.toml)"
```
Swap `zen.toml` for any other theme file in this directory.

**Modify a segment** — open `zen.toml`, find the `[[blocks.segments]]` entry with the `type` you want (e.g. `type = 'git'`), and edit its `template`, colors, or `[blocks.segments.properties]`.

**Add a new segment** — append a new `[[blocks.segments]]` block inside the appropriate `[[blocks]]` section:
```toml
[[blocks.segments]]
  type = 'node'          # segment type from oh-my-posh docs
  style = 'plain'
  foreground = '#44ff44'
  background = 'transparent'
  template = '  {{ .Full }} '
```

**Apply changes** — reload the shell:
```zsh
exec zsh
```
No NixOS rebuild needed; `~/.config/oh-my-posh/` is symlinked directly from this repo.

---

## Structure

| File | Description |
|------|-------------|
| `zen.toml` | Active theme — red/black powerline style |
| `zen.toml.bak` | Previous theme (light blue/pastel, kept as reference) |

---

## Active Theme

**`zen.toml`** — a red/black Powerline theme with Nerd Font icons.

Layout: three prompt lines plus a right-side prompt.

```
[os] [user@host] [git status] [nix?]   execution-time  python  node  go  battery
/full/path
❯
```

- Line 1 (left): OS icon → session → git → nix shell indicator
- Line 2 (left): full working directory path (plain, no background)
- Line 3 (left): `❯` prompt character (red on success, bright red on error)
- Right prompt: execution time, language versions, battery

---

## Segments

### Left prompt (line 1)

| Segment | Type | Notes |
|---------|------|-------|
| OS icon | `os` | Distro/OS icon; red diamond bg; cached 1h |
| Session | `session` | `user@hostname`; SSH indicator (`󱘖`) when in SSH session; black bg; cached 1h |
| Git | `git` | Branch, ahead/behind, untracked (`󰝒`), modified (`󰷈`), deleted (`󰮘`), staged-added (`󰐗`), staged-modified (`󰄬`), stash (`󰆓`); bg color shifts by state; cached 5m |
| Nix shell | `envvar` | Shows ` nix` only when `$IN_NIX_SHELL` is set (i.e. inside `nix develop` / `nix-shell`); blue bg |

### Left prompt (line 2)

| Segment | Type | Notes |
|---------|------|-------|
| Path | `path` | Full path (`style = 'full'`); transparent bg, grey fg |

### Right prompt

| Segment | Type | Notes |
|---------|------|-------|
| Execution time | `executiontime` | Shows elapsed time for commands taking >2s |
| Python | `python` | Version; only shown when a Python env is detected; cached 10m |
| Node | `node` | Version; only shown in Node projects; green fg; cached 10m |
| Go | `go` | Version; only shown in Go projects; cyan fg; cached 10m |
| Battery | `battery` | Icon + percentage; green >50%, orange 20–50%, red <20%; cached 1m |

### Prompts

| Prompt | Template | Notes |
|--------|----------|-------|
| Secondary | `❯❯ ` | Shown for multi-line input continuation |
| Transient | `❯ ` | Replaces previous prompts in history; red on success, bright red on error |

---

## Apply Changes

```zsh
exec zsh        # reload shell in place
```

Or open a new terminal. No rebuild step required.
