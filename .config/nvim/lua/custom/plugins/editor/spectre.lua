-- Project-wide find and replace
return {
  'nvim-pack/nvim-spectre',
  dependencies = { 'nvim-lua/plenary.nvim' },
  cmd = 'Spectre',
  keys = {
    { '<leader>sr', function() require('spectre').toggle() end, desc = 'Search and Replace (Spectre)' },
    { '<leader>sw', function() require('spectre').open_visual({ select_word = true }) end, desc = 'Search current word' },
    { '<leader>sw', function() require('spectre').open_visual() end, mode = 'v', desc = 'Search selection' },
    { '<leader>sp', function() require('spectre').open_file_search({ select_word = true }) end, desc = 'Search in current file' },
  },
  opts = {
    open_cmd = 'noswapfile vnew',
  },
}
