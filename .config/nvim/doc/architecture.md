# Neovim Configuration Architecture

## Overview

This configuration is built on [lazy.nvim](https://github.com/folke/lazy.nvim) (derived from kickstart.nvim) with a modular architecture designed for cross-platform compatibility across NixOS, Linux, and macOS.

## Directory Structure

```
.config/nvim/
├── init.lua                      # Entry point
├── doc/                          # Documentation
│   ├── architecture.md           # This file
│   └── reorganization-*.md       # Migration docs
└── lua/
    ├── kickstart/                # Upstream kickstart plugins
    │   └── plugins/
    │       ├── autopairs.lua
    │       ├── debug.lua
    │       └── indent_line.lua
    └── custom/                   # Custom configuration
        ├── platform.lua          # Platform detection module
        ├── configs/              # Core configuration
        │   ├── options.lua       # Vim options
        │   ├── keymaps.lua       # Global keybindings
        │   ├── hl-yank.lua       # Highlight on yank
        │   ├── autoformat.lua    # Auto-format settings
        │   └── lsp/              # LSP configuration
        │       ├── servers.lua   # Server definitions
        │       └── keymaps.lua   # LSP-specific keymaps
        └── plugins/              # Plugin specifications
            ├── editor/           # Editor enhancements
            ├── lsp/              # LSP & completion
            ├── git/              # Git integration
            ├── lang/             # Language-specific
            ├── ui/               # UI components
            └── nav/              # Navigation
```

## Core Modules

### Platform Detection (`lua/custom/platform.lua`)

Centralized platform detection providing:

```lua
local platform = require('custom.platform')

platform.is_macos      -- true on macOS
platform.is_linux      -- true on Linux (non-macOS)
platform.is_nixos      -- true on NixOS
platform.is_nix        -- true in any Nix environment (NixOS or nix-shell)
platform.use_mason     -- true when Mason should manage LSP servers
platform.homebrew_prefix  -- '/opt/homebrew' on macOS, nil otherwise
```

**Key behavior:** `use_mason` is `false` on Nix environments (LSP servers provided by Nix), `true` elsewhere (Mason installs them).

### LSP Configuration (`lua/custom/configs/lsp/`)

#### `servers.lua`
Defines all LSP server configurations:

```lua
M.servers = {
  lua_ls = { settings = { ... } },
  gopls = { settings = { ... } },
  ruff = { settings = { ... } },
  -- etc.
}

M.mason_tools = { 'stylua' }  -- Additional tools for Mason

M.setup_manual_servers(lspconfig)  -- Servers not in lspconfig (e.g., ty)
```

#### `keymaps.lua`
LSP keybindings attached on `LspAttach`:

| Key | Action |
|-----|--------|
| `gd` | Go to definition |
| `gr` | Go to references |
| `gI` | Go to implementation |
| `gD` | Go to declaration |
| `K` | Hover documentation |
| `<leader>rn` | Rename |
| `<leader>ca` | Code action |
| `<leader>ds` | Document symbols |
| `<leader>ws` | Workspace symbols |
| `<leader>th` | Toggle inlay hints |

## Plugin Categories

### `plugins/editor/` - Editor Enhancements
- **treesitter.lua** - Syntax highlighting & text objects
- **telescope.lua** - Fuzzy finder
- **telescope-undo.lua** - Undo tree visualization
- **oil.lua** - File explorer
- **mini.lua** - Mini.nvim utilities (surround, etc.)
- **vim-sleuth.lua** - Auto-detect indentation
- **comment.lua** - Code commenting
- **todo-comments.lua** - Highlight TODOs
- **obsidian.lua** - Obsidian vault integration

### `plugins/lsp/` - LSP & Completion
- **lspconfig.lua** - LSP client configuration
- **blink.lua** - Completion engine
- **conform.lua** - Formatting
- **nvim-cmp.lua** - Legacy completion (if needed)
- **lsp_signature.lua** - Function signature help

### `plugins/git/` - Git Integration
- **neogit.lua** - Magit-like git interface
- **gitsigns.lua** - Git signs in gutter

### `plugins/lang/` - Language-Specific
- **go.lua** - Go development (gopher.nvim)
- **flutter.lua** - Flutter/Dart development

### `plugins/ui/` - UI Components
- **theme.lua** - Tokyonight colorscheme
- **alpha.lua** - Dashboard/start screen
- **which-key.lua** - Keybinding hints
- **grapple.lua** - File tagging/jumping

### `plugins/nav/` - Navigation
- **tmux-nav.lua** - Seamless tmux/nvim navigation

## Data Flow

```
init.lua
    │
    ├── require 'custom.configs.options'     # Vim settings
    ├── require 'custom.configs.keymaps'     # Global keys
    ├── require 'custom.configs.hl-yank'     # Autocommands
    │
    └── lazy.setup({
            require 'kickstart.plugins.*'    # Base plugins
            { import = 'custom.plugins.editor' }
            { import = 'custom.plugins.lsp' }
            { import = 'custom.plugins.git' }
            { import = 'custom.plugins.lang' }
            { import = 'custom.plugins.ui' }
            { import = 'custom.plugins.nav' }
        })
```

## Platform-Specific Behavior

### NixOS / Nix Shell
- Mason disabled (`platform.use_mason = false`)
- LSP servers provided by Nix packages
- Direct lspconfig setup without Mason

### Linux / macOS (non-Nix)
- Mason enabled (`platform.use_mason = true`)
- Mason installs and manages LSP servers
- mason-lspconfig handles server setup

## Design Principles

1. **Single source of truth** - Platform logic in one place
2. **Lazy loading** - Plugins load on demand via lazy.nvim
3. **Separation of concerns** - Configs vs plugins vs keymaps
4. **Category organization** - Plugins grouped by function
5. **Cross-platform first** - Works on NixOS, Linux, macOS
