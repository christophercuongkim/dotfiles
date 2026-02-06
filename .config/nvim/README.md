# Neovim Configuration

Cross-platform Neovim configuration supporting NixOS, Linux, and macOS. Based on [kickstart.nvim](https://github.com/nvim-lua/kickstart.nvim) with a modular architecture.

## Quick Start

**On NixOS:** Config is automatically symlinked via home-manager.

**On other systems:**
```bash
# Symlink the config
ln -sf ~/dotfiles/.config/nvim ~/.config/nvim

# Start nvim (lazy.nvim will auto-install on first run)
nvim
```

## Structure

```
lua/custom/
├── platform.lua          # Platform detection
├── configs/              # Core settings
│   ├── options.lua       # Vim options
│   ├── keymaps.lua       # Global keybindings
│   └── lsp/              # LSP configuration
│       ├── servers.lua   # Server configs
│       └── keymaps.lua   # LSP keymaps
└── plugins/              # Plugin specs (by category)
    ├── editor/           # treesitter, telescope, oil...
    ├── lsp/              # lspconfig, completion...
    ├── git/              # neogit, gitsigns
    ├── lang/             # go, flutter
    ├── ui/               # theme, which-key...
    └── nav/              # tmux navigation
```

See [doc/architecture.md](doc/architecture.md) for detailed documentation.

## How To...

### Add a New Plugin

1. Determine the category (`editor`, `lsp`, `git`, `lang`, `ui`, `nav`)
2. Create a file in `lua/custom/plugins/<category>/<plugin-name>.lua`
3. Return a lazy.nvim plugin spec:

```lua
-- lua/custom/plugins/editor/example.lua
return {
  'author/plugin-name',
  event = 'VeryLazy',  -- or other lazy-loading trigger
  opts = {
    -- plugin options
  },
}
```

That's it! lazy.nvim auto-imports all files in the category directories.

### Add a New LSP Server

1. Edit `lua/custom/configs/lsp/servers.lua`
2. Add the server to `M.servers`:

```lua
M.servers = {
  -- existing servers...

  new_server = {
    settings = {
      new_server = {
        -- server-specific settings
      },
    },
  },
}
```

3. **On NixOS:** Add the server package to your Nix config
4. **On other systems:** Mason will auto-install it

### Add a New Keymap

**Global keymaps:** Edit `lua/custom/configs/keymaps.lua`

```lua
vim.keymap.set('n', '<leader>xx', function()
  -- your action
end, { desc = 'Description' })
```

**LSP keymaps:** Edit `lua/custom/configs/lsp/keymaps.lua`

```lua
-- Inside M.on_attach(event)
map('<leader>xx', vim.lsp.buf.something, '[X] Description')
```

### Add Language-Specific Configuration

1. Create `lua/custom/plugins/lang/<language>.lua`
2. Add the language plugin and any LSP config:

```lua
-- lua/custom/plugins/lang/rust.lua
return {
  {
    'simrat39/rust-tools.nvim',
    ft = 'rust',
    opts = {
      -- rust-tools options
    },
  },
}
```

3. Add the LSP server to `configs/lsp/servers.lua` if needed

### Check Platform at Runtime

```lua
local platform = require('custom.platform')

if platform.is_nixos then
  -- NixOS-specific code
elseif platform.is_macos then
  -- macOS-specific code
end

if platform.use_mason then
  -- Only runs when Mason manages LSP servers
end
```

### Disable a Plugin

Option 1: Delete the file

Option 2: Set `enabled = false`:
```lua
return {
  'author/plugin',
  enabled = false,
}
```

### Add Platform-Specific Plugin

```lua
local platform = require('custom.platform')

return {
  'author/plugin',
  enabled = platform.is_macos,  -- Only on macOS
  -- or
  enabled = platform.use_mason,  -- Only when using Mason
}
```

## Key Bindings

| Key | Action |
|-----|--------|
| `<Space>` | Leader key |
| `<leader>sf` | Search files |
| `<leader>sg` | Search grep |
| `<leader>sb` | Search buffers |
| `<leader>e` | Show diagnostics |
| `gd` | Go to definition |
| `gr` | Go to references |
| `K` | Hover docs |
| `<leader>ca` | Code action |
| `<leader>rn` | Rename |
| `<C-h/j/k/l>` | Navigate splits (tmux-aware) |
| `jj` | Exit insert mode |

Run `:Telescope keymaps` or press a key and wait for which-key hints.

## Commands

| Command | Action |
|---------|--------|
| `:Lazy` | Plugin manager UI |
| `:Mason` | LSP installer UI (non-Nix only) |
| `:LspInfo` | LSP status |
| `:checkhealth` | Diagnose issues |

## Troubleshooting

**Plugins not loading?**
```vim
:Lazy
```
Check for errors, try `I` to install, `U` to update.

**LSP not working?**
```vim
:LspInfo
:checkhealth lsp
```

**On NixOS, changes not reflecting?**
Rebuild: `sudo nixos-rebuild switch --flake .`

**Check platform detection:**
```vim
:lua require('custom.platform').print_info()
```

## External Dependencies

- `git`, `make`, `unzip`, C compiler (`gcc`)
- [ripgrep](https://github.com/BurntSushi/ripgrep) for telescope grep
- Clipboard tool (`wl-copy` on Wayland, `xclip` on X11)
- [Nerd Font](https://www.nerdfonts.com/) for icons

On NixOS, these are provided by the system configuration.
