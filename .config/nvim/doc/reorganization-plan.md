# Neovim Config Reorganization Plan

## Goal
Full restructure of nvim config with better organization and cross-platform compatibility (NixOS, Linux, macOS).

## Scope
- **Full restructure** - Reorganize plugins into subdirectories
- Add centralized platform detection
- Simplify LSP configuration
- Support NixOS, other Linux, and macOS

## Current State
- lazy.nvim based config (kickstart.nvim derived)
- Platform detection: `vim.fn.executable('nix-shell') == 1`
- Mason disabled on NixOS, enabled elsewhere
- 23+ plugins flat in `lua/custom/plugins/`

## Proposed Changes

### 1. Improved Platform Detection Module

Create `lua/custom/platform.lua`:
```lua
local M = {}

M.is_nixos = vim.fn.executable('nix-shell') == 1 and vim.fn.isdirectory('/etc/nixos') == 1
M.is_macos = vim.fn.has('macOS') == 1 or vim.uv.os_uname().sysname == 'Darwin'
M.is_linux = vim.fn.has('unix') == 1 and not M.is_macos
M.is_nix = M.is_nixos or (vim.fn.executable('nix') == 1 and vim.env.IN_NIX_SHELL ~= nil)

-- LSP/tool management strategy
M.use_mason = not M.is_nix

return M
```

Benefits:
- Centralized platform logic
- Detects macOS properly
- Distinguishes nix-shell on non-NixOS (e.g., nix on macOS)
- Single source of truth

### 2. Reorganize Plugin Structure

Current:
```
lua/custom/plugins/
├── lspconfig.lua      # 200+ lines, mixed concerns
├── treesitter.lua
├── ... (21 more files)
```

Proposed:
```
lua/custom/
├── platform.lua           # NEW: Platform detection
├── configs/
│   ├── options.lua
│   ├── keymaps.lua        # Rename from basic_keymap.lua
│   ├── autocmds.lua       # Rename from hl-yank.lua + others
│   └── lsp/
│       ├── init.lua       # LSP setup orchestrator
│       ├── servers.lua    # Server configurations
│       └── keymaps.lua    # LSP-specific keymaps
├── plugins/
│   ├── editor/            # Editor enhancements
│   │   ├── treesitter.lua
│   │   ├── telescope.lua
│   │   ├── oil.lua
│   │   └── mini.lua
│   ├── lsp/               # LSP & completion
│   │   ├── lspconfig.lua  # Simplified, uses configs/lsp/
│   │   ├── blink.lua
│   │   └── conform.lua
│   ├── git/               # Git integration
│   │   ├── neogit.lua
│   │   └── gitsigns.lua
│   ├── lang/              # Language-specific
│   │   ├── go.lua         # gopher + go-specific
│   │   ├── flutter.lua
│   │   └── python.lua     # ruff, ty config
│   └── ui/                # UI components
│       ├── theme.lua
│       ├── alpha.lua
│       └── which-key.lua
```

### 3. LSP Config Simplification

Extract server configs to `lua/custom/configs/lsp/servers.lua`:
```lua
local platform = require('custom.platform')

local M = {}

M.servers = {
  lua_ls = {
    settings = { Lua = { ... } },
  },
  gopls = {
    settings = { gopls = { ... } },
  },
  -- etc.
}

-- Platform-specific server availability
M.mason_ensure_installed = platform.use_mason and {
  'lua-language-server',
  'gopls',
  'stylua',
  -- etc.
} or {}

return M
```

### 4. macOS-Specific Considerations

Add to `platform.lua`:
```lua
-- Clipboard handling
if M.is_macos then
  vim.opt.clipboard = 'unnamedplus'
  -- Use pbcopy/pbpaste
end

-- Path adjustments for Homebrew
M.homebrew_prefix = M.is_macos and '/opt/homebrew' or nil
```

### 5. Update lspconfig.lua

Simplify to use the new modules:
```lua
local platform = require('custom.platform')
local servers = require('custom.configs.lsp.servers')

return {
  'neovim/nvim-lspconfig',
  dependencies = platform.use_mason and {
    'williamboman/mason.nvim',
    'williamboman/mason-lspconfig.nvim',
  } or {},
  config = function()
    -- Use servers.lua for configuration
    -- Use platform.lua for detection
  end,
}
```

## Implementation Steps

### Step 1: Create platform detection module
- Create `lua/custom/platform.lua`

### Step 2: Create LSP config modules
- Create `lua/custom/configs/lsp/init.lua`
- Create `lua/custom/configs/lsp/servers.lua`
- Create `lua/custom/configs/lsp/keymaps.lua`

### Step 3: Rename config files
- `lua/custom/configs/basic_keymap.lua` → `lua/custom/configs/keymaps.lua`
- Update import in `init.lua`

### Step 4: Reorganize plugins into subdirectories
Create directories and move files:

```
lua/custom/plugins/
├── editor/
│   ├── init.lua           # imports all editor plugins
│   ├── treesitter.lua     # from plugins/treesitter.lua
│   ├── telescope.lua      # from plugins/telescope.lua
│   ├── telescope-undo.lua
│   ├── oil.lua
│   ├── mini.lua
│   ├── vim-sleuth.lua
│   ├── comment.lua
│   └── todo-comments.lua
├── lsp/
│   ├── init.lua           # imports all lsp plugins
│   ├── lspconfig.lua      # simplified, uses configs/lsp/
│   ├── blink.lua
│   ├── conform.lua
│   ├── nvim-cmp.lua
│   └── lsp_signature.lua
├── git/
│   ├── init.lua
│   ├── neogit.lua
│   └── gitsigns.lua
├── lang/
│   ├── init.lua
│   ├── go.lua             # gopher.lua renamed
│   ├── flutter.lua
│   └── python.lua         # NEW: extract from lspconfig
├── ui/
│   ├── init.lua
│   ├── theme.lua          # tokyonight.lua renamed
│   ├── alpha.lua
│   ├── which-key.lua
│   └── grapple.lua
└── nav/
    ├── init.lua
    └── tmux-nav.lua
```

### Step 5: Update init.lua imports
Update `init.lua` to use new structure:
```lua
require('lazy').setup({
  require 'kickstart.plugins.debug',
  require 'kickstart.plugins.indent_line',
  require 'kickstart.plugins.autopairs',
  { import = 'custom.plugins.editor' },
  { import = 'custom.plugins.lsp' },
  { import = 'custom.plugins.git' },
  { import = 'custom.plugins.lang' },
  { import = 'custom.plugins.ui' },
  { import = 'custom.plugins.nav' },
})
```

### Step 6: Update lspconfig to use new modules
- Import platform.lua for detection
- Import servers.lua for server configs
- Import keymaps.lua for LSP keymaps
- Simplify main lspconfig.lua

### Step 7: Test
- Test on NixOS (current machine)
- Verify lazy.nvim loads all plugins
- Verify LSP servers work
- Verify Mason is disabled on NixOS

## Files Summary

**Create (11 files):**
- `lua/custom/platform.lua`
- `lua/custom/configs/lsp/init.lua`
- `lua/custom/configs/lsp/servers.lua`
- `lua/custom/configs/lsp/keymaps.lua`
- `lua/custom/plugins/editor/init.lua`
- `lua/custom/plugins/lsp/init.lua`
- `lua/custom/plugins/git/init.lua`
- `lua/custom/plugins/lang/init.lua`
- `lua/custom/plugins/lang/python.lua`
- `lua/custom/plugins/ui/init.lua`
- `lua/custom/plugins/nav/init.lua`

**Move/Rename (20+ files):**
- Move plugins to appropriate subdirectories
- Rename `basic_keymap.lua` → `keymaps.lua`
- Rename `tokyonight.lua` → `theme.lua`
- Rename `gopher.lua` → `go.lua`

**Modify (2 files):**
- `init.lua` - update imports
- `lua/custom/plugins/lsp/lspconfig.lua` - simplify using new modules

## Benefits

- Single source of truth for platform detection
- Easier to add new platforms (macOS, WSL, etc.)
- LSP config is modular and readable
- Plugins organized by function (easy to find/maintain)
- macOS clipboard/path handling built-in
- Each category can be enabled/disabled easily
