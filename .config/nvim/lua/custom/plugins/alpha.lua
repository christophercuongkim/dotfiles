return {
  {
    'goolord/alpha-nvim',
    -- dependencies = { 'echasnovski/mini.icons' },
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    config = function()
      local theta = require 'alpha.themes.theta'
      local dashboard = require 'alpha.themes.dashboard'
      -- available: devicons, mini, default is mini
      -- if provider not loaded and enabled is true, it will try to use another provider
      theta.file_icons.provider = 'mini'
      theta.buttons.val = {
        { type = 'text', val = 'Quick links', opts = { hl = 'SpecialComment', position = 'center' } },
        { type = 'padding', val = 1 },
        dashboard.button('e', '  New file', '<cmd>ene<CR>'),
        dashboard.button('SPC s f', '󰈞  Find file'),
        dashboard.button('SPC s g', '󰊄  Live grep'),
        dashboard.button('c', '  Configuration', "<cmd>cd stdpath('config')<CR>"),
        dashboard.button('u', '  Update plugins', '<cmd>Lazy sync<CR>'),
        dashboard.button('q', '󰅚  Quit', '<cmd>qa<CR>'),
      }
      require('alpha').setup(theta.config)
    end,
  },
}
