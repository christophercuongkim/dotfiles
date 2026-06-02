# Neovim Configuration

NixOS-primary Neovim configuration with a modular architecture built on top of [kickstart.nvim](https://github.com/nvim-lua/kickstart.nvim). Uses [lazy.nvim](https://github.com/folke/lazy.nvim) for plugin management and [blink.cmp](https://github.com/saghen/blink.cmp) for completion.

## Quick Start

### Making Changes (NixOS)

Config files live in `/home/chriskim/dotfiles/.config/nvim/` and are symlinked to `~/.config/nvim/` via home-manager. Since the symlink points directly here, **edits take effect immediately** — just save and restart Neovim.

If you add a new symlink or change `modules/features/dotfiles/symlinks.nix`, rebuild:
```bash
sudo nixos-rebuild switch --flake .#AppleII
```

### Add a Plugin

1. Pick the right category directory under `lua/custom/plugins/`
2. Create a new file there (e.g. `lua/custom/plugins/editor/my-plugin.lua`)
3. Return a lazy.nvim spec:

```lua
return {
  'author/plugin-name',
  event = 'VeryLazy',
  opts = {
    -- plugin options
  },
}
```

lazy.nvim auto-imports everything in the category directories — no registration needed.

### Add a Keymap

**Global:** Edit `lua/custom/configs/keymaps.lua`
```lua
vim.keymap.set('n', '<leader>xx', function()
  -- action
end, { desc = 'Description' })
```

**LSP-attached:** Edit `lua/custom/configs/lsp/keymaps.lua` inside `M.on_attach(event)`
```lua
map('<leader>xx', vim.lsp.buf.something, '[X] Description')
```

### Add an LSP Server

1. Edit `lua/custom/configs/lsp/servers.lua`, add to `M.servers`:
```lua
my_server = {
  settings = { ... },
},
```
2. On NixOS, add the server binary to your Nix config (e.g. `modules/features/development/lsp.nix`) and rebuild.
3. On non-Nix systems, Mason will auto-install it.

### Change Editor Options

Edit `lua/custom/configs/options.lua`. Standard `vim.opt.*` settings.

---

## Structure

```
.config/nvim/
├── init.lua                        # Entry point: loads options, keymaps, lazy.nvim, plugins
├── lua/
│   ├── custom/
│   │   ├── platform.lua            # Platform/Nix detection
│   │   ├── configs/
│   │   │   ├── options.lua         # vim.opt settings (tabs, numbers, clipboard, etc.)
│   │   │   ├── keymaps.lua         # Global keymaps (diagnostics, splits, jj, tmux nav)
│   │   │   ├── hl-yank.lua         # Highlight-on-yank autocommand
│   │   │   ├── autoformat.lua      # LSP format-on-save helper (used by lspconfig)
│   │   │   └── lsp/
│   │   │       ├── servers.lua     # LSP server configs + Mason tool list
│   │   │       └── keymaps.lua     # LSP keymaps (gd, gr, K, <leader>rn, etc.)
│   │   └── plugins/
│   │       ├── db/
│   │       │   └── dbee.lua        # nvim-dbee SQL client
│   │       ├── editor/
│   │       │   ├── comment.lua     # Comment.nvim
│   │       │   ├── crates.lua      # Rust crates.io integration
│   │       │   ├── mini.lua        # mini.nvim collection
│   │       │   ├── obsidian.lua    # Obsidian.nvim (markdown notes, ~/notes/chris_notes)
│   │       │   ├── oil.lua         # Oil.nvim (file manager in a buffer)
│   │       │   ├── render-markdown.lua  # Rendered markdown in buffer
│   │       │   ├── spectre.lua     # Project-wide find & replace
│   │       │   ├── telescope.lua   # Fuzzy finder + keymaps
│   │       │   ├── telescope-undo.lua   # Telescope undo history
│   │       │   ├── todo-comments.lua    # TODO/FIXME highlighting
│   │       │   ├── treesitter-context.lua  # Sticky function context header
│   │       │   ├── treesitter.lua  # Treesitter parsers + text objects
│   │       │   └── vim-sleuth.lua  # Auto-detect indent settings
│   │       ├── git/
│   │       │   ├── gitsigns.lua    # Inline git hunks + blame
│   │       │   └── neogit.lua      # Magit-style git UI + diffview
│   │       ├── lang/
│   │       │   ├── flutter.lua     # Flutter/Dart tooling
│   │       │   ├── go.lua          # gopher.nvim (Go tags, snippets, test gen)
│   │       │   └── rust.lua        # rustaceanvim
│   │       ├── lsp/
│   │       │   ├── blink.lua       # blink.cmp completion engine
│   │       │   ├── conform.lua     # Formatting (stylua, ruff, clang-format)
│   │       │   ├── debug.lua       # nvim-dap + dapui (Go, Python, C/C++)
│   │       │   ├── lint.lua        # nvim-lint
│   │       │   ├── lspconfig.lua   # nvim-lspconfig + Mason setup
│   │       │   ├── lsp_signature.lua  # Signature help popup
│   │       │   ├── neotest.lua     # Test runner (currently disabled)
│   │       │   ├── nvim-cmp.lua    # (legacy, superseded by blink.cmp)
│   │       │   └── trouble.lua     # Diagnostics list UI
│   │       ├── nav/
│   │       │   ├── aerial.lua      # Code outline sidebar (<leader>a)
│   │       │   └── tmux-nav.lua    # vim-tmux-navigator (<C-h/j/k/l>)
│   │       └── ui/
│   │           ├── alpha.lua       # Start screen (alpha-nvim, theta theme)
│   │           ├── grapple.lua     # File bookmarks/tags (<leader>m)
│   │           ├── theme.lua       # tokyonight-night colorscheme
│   │           └── which-key.lua   # Key hint popups
│   └── kickstart/
│       ├── health.lua              # :checkhealth integration
│       └── plugins/
│           ├── autopairs.lua       # Auto-close brackets (loaded directly in init.lua)
│           ├── indent_line.lua     # Indent guides (loaded directly in init.lua)
│           └── ...                 # Other kickstart stubs (mostly superseded by custom/)
└── doc/                            # Planning/architecture docs (historical)
```

---

## Key Files

| File | Purpose |
|------|---------|
| `init.lua` | Entry point. Loads options, keymaps, hl-yank, then bootstraps lazy.nvim and imports all plugin specs. Lockfile stored in `stdpath('data')` since config dir is read-only on NixOS. |
| `lua/custom/platform.lua` | Detects NixOS, nix-shell, macOS, Linux. Sets `platform.use_mason = not is_nix` to control whether Mason manages tools. |
| `lua/custom/configs/options.lua` | All `vim.opt` settings: relative numbers, 2-space tabs, `unnamedplus` clipboard, `undofile`, etc. |
| `lua/custom/configs/keymaps.lua` | Global keymaps. Arrow keys disabled. `jj` exits insert. `<C-h/j/k/l>` delegates to TmuxNavigate commands. |
| `lua/custom/configs/lsp/servers.lua` | LSP server configs for: `dartls`, `clangd`, `lua_ls`, `gopls`, `ty` (Python types), `ruff` (Python lint/format). Also lists `mason_tools = { 'stylua' }` for non-Nix installs. |
| `lua/custom/configs/lsp/keymaps.lua` | Sets up LSP keymaps on `LspAttach`: `gd/gr/gI/gD`, `<leader>rn`, `<leader>ca`, `K`, `<leader>th` (inlay hints toggle). Disables `ruff` hover to avoid conflict with `ty`. |
| `lua/custom/plugins/lsp/lspconfig.lua` | Configures all servers using `vim.lsp.config` (Neovim 0.11+ API). Gets capabilities from blink.cmp. Mason only runs when `platform.use_mason` is true. |
| `lua/custom/plugins/lsp/blink.lua` | blink.cmp completion. Sources: LSP, path, snippets, buffer. `<leader>tc` toggles completion on/off. |
| `lua/custom/plugins/lsp/conform.lua` | Format on save via conform.nvim. `<leader>f` for manual format. Formatters: `stylua` (Lua), `ruff` (Python), `clang-format` (C/C++). |
| `lua/custom/plugins/lsp/debug.lua` | Full DAP setup for Go (delve), Python (debugpy), and C/C++ (lldb). NixOS configures adapters manually; non-Nix uses Mason. |

---

## Plugin Manager

**lazy.nvim** — bootstrapped in `init.lua`. All plugin specs live under `lua/custom/plugins/` organized by category. lazy.nvim auto-imports each subdirectory via `{ import = 'custom.plugins.<category>' }`.

The lockfile is stored at `vim.fn.stdpath('data') .. '/lazy-lock.json'` (not in the config dir) because the NixOS symlinked config directory is read-only.

Key commands:
- `:Lazy` — plugin manager UI (install, update, profile)
- `:Lazy sync` — update all plugins

---

## Customization

### Where to Make Common Changes

| Task | File |
|------|------|
| Add/change vim options | `lua/custom/configs/options.lua` |
| Add global keymap | `lua/custom/configs/keymaps.lua` |
| Add LSP keymap | `lua/custom/configs/lsp/keymaps.lua` |
| Add/configure LSP server | `lua/custom/configs/lsp/servers.lua` |
| Add formatter | `lua/custom/plugins/lsp/conform.lua` → `formatters_by_ft` |
| Change colorscheme | `lua/custom/plugins/ui/theme.lua` |
| Add a plugin | New file in `lua/custom/plugins/<category>/` |
| Language-specific plugin | New file in `lua/custom/plugins/lang/` |
| Debug adapter | `lua/custom/plugins/lsp/debug.lua` |

### Disable a Plugin

Option 1: Delete the file.

Option 2: Set `enabled = false` in the spec:
```lua
return {
  'author/plugin',
  enabled = false,
}
```

### Platform-Conditional Plugins

Use `platform.lua` to gate plugins or behavior:

```lua
local platform = require('custom.platform')

return {
  'author/plugin',
  enabled = platform.use_mason,  -- only on non-Nix systems
}
```

Available flags: `is_nixos`, `is_nix`, `is_macos`, `is_linux`, `use_mason`.

Debug at runtime: `:lua require('custom.platform').print_info()`

---

## NixOS Package Requirements

Mason is disabled on NixOS. All external tools must be in the Nix config.

| Tool | Nix package | Used by |
|------|-------------|---------|
| `lua-language-server` | `lua-language-server` | Lua LSP |
| `gopls` | `gopls` | Go LSP |
| `ty` | `ty` | Python type checking |
| `ruff` | `ruff` | Python linting + formatting |
| `clangd` | `clang-tools` | C/C++ LSP |
| `stylua` | `stylua` | Lua formatting |
| `dlv` (delve) | `delve` | Go DAP |
| `debugpy-adapter` | `python3Packages.debugpy` | Python DAP |
| `lldb-dap` | `lldb` | C/C++ DAP |
| `fd` | `fd` | Telescope file search |
| `ripgrep` | `ripgrep` | Telescope grep |
| `gcc`, `make` | `gcc`, `gnumake` | Treesitter parser compilation |

These are managed in `modules/features/development/lsp.nix` (and related modules) in the dotfiles repo.

---

## Key Bindings Reference

| Key | Action |
|-----|--------|
| `<Space>` | Leader key |
| `jj` | Exit insert mode |
| `<C-h/j/k/l>` | Navigate splits (tmux-aware) |
| `<leader>sf` | Search files (Telescope) |
| `<leader>sg` | Live grep (Telescope) |
| `<leader><leader>` | Find open buffers |
| `<leader>s.` | Recent files |
| `<leader>e` | Show diagnostics float |
| `<leader>q` | Diagnostics quickfix list |
| `<leader>xx` | Trouble diagnostics toggle |
| `<leader>f` | Format buffer |
| `gd` | Go to definition |
| `gr` | Go to references |
| `K` | Hover docs |
| `<leader>rn` | Rename symbol |
| `<leader>ca` | Code action |
| `<leader>th` | Toggle inlay hints |
| `<leader>tc` | Toggle autocomplete |
| `<leader>a` | Toggle Aerial (code outline) |
| `<leader>m` | Grapple tag file |
| `<leader>M` | Grapple tags window |
| `<leader>n/p` | Cycle grapple tags |
| `<leader>1-5` | Jump to grapple tag by index |
| `<leader>ngo` | Open Neogit |
| `<leader>dc` | Debug: start/continue |
| `<leader>db` | Debug: toggle breakpoint |
| `<leader>dd` | Debug: toggle UI |
| `<leader>bt` | Toggle DB (dbee) |
| `<leader>Rt` | Spectre find & replace |

Run `:Telescope keymaps` or press a key prefix and wait for which-key hints.

---

## Troubleshooting

**Plugins not loading?**
```vim
:Lazy
```

**LSP not working?**
```vim
:LspInfo
:checkhealth lsp
```

**Treesitter issues?**
```vim
:TSInstall <language>
:checkhealth nvim-treesitter
```

**NixOS: changes not applying?**
Symlinks are live, so Lua changes apply immediately. If symlinks are missing:
```bash
sudo nixos-rebuild switch --flake .#AppleII
```
