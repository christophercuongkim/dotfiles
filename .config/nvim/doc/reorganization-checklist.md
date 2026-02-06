# Neovim Reorganization Checklist

## Phase 1: Foundation
- [x] Create `lua/custom/platform.lua` - centralized platform detection

## Phase 2: LSP Config Modules
- [x] Create `lua/custom/configs/lsp/` directory
- [x] Create `lua/custom/configs/lsp/servers.lua` - server configurations
- [x] Create `lua/custom/configs/lsp/keymaps.lua` - LSP keybindings

## Phase 3: Config Renames
- [x] Rename `lua/custom/configs/basic_keymap.lua` → `keymaps.lua`
- [x] Update import in `init.lua`

## Phase 4: Plugin Directory Structure
- [x] Create `lua/custom/plugins/editor/` directory
- [x] Create `lua/custom/plugins/lsp/` directory
- [x] Create `lua/custom/plugins/git/` directory
- [x] Create `lua/custom/plugins/lang/` directory
- [x] Create `lua/custom/plugins/ui/` directory
- [x] Create `lua/custom/plugins/nav/` directory

## Phase 5: Move Editor Plugins
- [x] Move `treesitter.lua` → `editor/`
- [x] Move `telescope.lua` → `editor/`
- [x] Move `telescope-undo.lua` → `editor/`
- [x] Move `oil.lua` → `editor/`
- [x] Move `mini.lua` → `editor/`
- [x] Move `vim-sleuth.lua` → `editor/`
- [x] Move `comment.lua` → `editor/`
- [x] Move `todo-comments.lua` → `editor/`
- [x] Move `obsidian.lua` → `editor/`

## Phase 6: Move LSP Plugins
- [x] Move `lspconfig.lua` → `lsp/`
- [x] Move `blink.lua` → `lsp/`
- [x] Move `conform.lua` → `lsp/`
- [x] Move `nvim-cmp.lua` → `lsp/`
- [x] Move `lsp_signature.lua` → `lsp/`

## Phase 7: Move Git Plugins
- [x] Move `neogit.lua` → `git/`
- [x] Move `gitsigns.lua` → `git/`

## Phase 8: Move Language Plugins
- [x] Move `gopher.lua` → `lang/go.lua`
- [x] Move `flutter.lua` → `lang/`
- [ ] Create `lang/python.lua` (extract from lspconfig) - SKIPPED: Python config already in configs/lsp/servers.lua

## Phase 9: Move UI Plugins
- [x] Move `tokyonight.lua` → `ui/theme.lua`
- [x] Move `alpha.lua` → `ui/`
- [x] Move `which-key.lua` → `ui/`
- [x] Move `grapple.lua` → `ui/`

## Phase 10: Move Nav Plugins
- [x] Move `tmux-nav.lua` → `nav/`

## Phase 11: Update lspconfig.lua
- [x] Refactor to use `platform.lua`
- [x] Refactor to use `configs/lsp/servers.lua`
- [x] Refactor to use `configs/lsp/keymaps.lua`

## Phase 12: Update init.lua
- [x] Update lazy.setup imports to use new structure

## Phase 13: Testing
**NOTE: Requires NixOS rebuild to apply symlink changes**
- [x] Run `sudo nixos-rebuild switch --flake .`
- [x] Test nvim starts without errors
- [x] Test LSP servers work (gopls, dartls, ty, lua_ls, ruff)
- [x] Test Mason is disabled on NixOS (use_mason: false)
- [x] Test all plugins load correctly (39 plugins)

## Phase 14: Cleanup
- [x] Old plugin files moved to subdirectories (no cleanup needed)
- [ ] Commit changes
