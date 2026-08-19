-- [[ Basic Options ]]
require 'custom.configs.options'

-- [[ Basic Keymaps ]]
require 'custom.configs.keymaps'

-- [[ Basic Autocommands ]]
--  See `:help lua-guide-autocommands`
require 'custom.configs.hl-yank'

-- [[ Install `lazy.nvim` plugin manager ]]
--    See `:help lazy.nvim.txt` or https://github.com/folke/lazy.nvim for more info
local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = 'https://github.com/folke/lazy.nvim.git'
  vim.fn.system { 'git', 'clone', '--filter=blob:none', '--branch=stable', lazyrepo, lazypath }
end ---@diagnostic disable-next-line: undefined-field
vim.opt.rtp:prepend(lazypath)

-- [[ Configure and install plugins ]]
--
--  To check the current status of your plugins, run
--    :Lazy
--
--  You can press `?` in this menu for help. Use `:q` to close the window
--
--  To update plugins you can run
--    :Lazy update
--
-- NOTE: Here is where you install your plugins.
require('lazy').setup({
  -- Debug config moved to custom.plugins.lsp.debug
  require 'kickstart.plugins.indent_line',
  require 'kickstart.plugins.autopairs',
  { import = 'custom.plugins.db' },
  { import = 'custom.plugins.editor' },
  { import = 'custom.plugins.git' },
  { import = 'custom.plugins.lang' },
  { import = 'custom.plugins.lsp' },
  { import = 'custom.plugins.nav' },
  { import = 'custom.plugins.ui' },
}, {
  -- Store lockfile in writable location (config dir is read-only on NixOS)
  lockfile = vim.fn.stdpath 'data' .. '/lazy-lock.json',
  ui = {
    -- default lazy.nvim defined Nerd Font icons, otherwise define a unicode icons table
    icons = vim.g.have_nerd_font and {} or {
      cmd = '⌘',
      config = '🛠',
      event = '📅',
      ft = '📂',
      init = '⚙',
      keys = '🗝',
      plugin = '🔌',
      runtime = '💻',
      require = '🌙',
      source = '📄',
      start = '🚀',
      task = '📌',
      lazy = '💤 ',
    },
  },
})

-- The line beneath this is called `modeline`. See `:help modeline`
-- vim: ts=2 sts=2 sw=2 et
