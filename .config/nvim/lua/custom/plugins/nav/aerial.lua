-- Code outline sidebar
return {
  'stevearc/aerial.nvim',
  dependencies = {
    'nvim-treesitter/nvim-treesitter',
    'nvim-tree/nvim-web-devicons',
  },
  cmd = { 'AerialToggle', 'AerialOpen', 'AerialNavToggle' },
  keys = {
    { '<leader>a', '<cmd>AerialToggle!<cr>', desc = 'Toggle Aerial (code outline)' },
    { '<leader>A', '<cmd>AerialNavToggle<cr>', desc = 'Toggle Aerial Nav' },
  },
  opts = {
    backends = { 'treesitter', 'lsp', 'markdown', 'man' },
    layout = {
      max_width = { 40, 0.2 },
      min_width = 20,
      default_direction = 'prefer_right',
    },
    attach_mode = 'global',
    filter_kind = false,
    show_guides = true,
    guides = {
      mid_item = '├─',
      last_item = '└─',
      nested_top = '│ ',
      whitespace = '  ',
    },
  },
}
