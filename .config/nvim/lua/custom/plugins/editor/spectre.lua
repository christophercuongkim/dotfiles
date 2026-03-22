-- Project-wide find and replace
return {
  'nvim-pack/nvim-spectre',
  dependencies = { 'nvim-lua/plenary.nvim' },
  cmd = 'Spectre',
  keys = {
    { '<leader>Rt', function() require('spectre').toggle() end, desc = '[R]eplace [T]oggle (Spectre)' },
    { '<leader>Rw', function() require('spectre').open_visual({ select_word = true }) end, desc = '[R]eplace current [W]ord' },
    { '<leader>Rw', function() require('spectre').open_visual() end, mode = 'v', desc = '[R]eplace selection' },
    { '<leader>Rf', function() require('spectre').open_file_search({ select_word = true }) end, desc = '[R]eplace in current [F]ile' },
  },
  opts = {
    open_cmd = 'noswapfile vnew',
  },
}
