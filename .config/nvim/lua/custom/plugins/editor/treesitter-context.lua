-- Sticky function/class context header
return {
  'nvim-treesitter/nvim-treesitter-context',
  event = 'VeryLazy',
  opts = {
    enable = true,
    max_lines = 3,
    min_window_height = 0,
    line_numbers = true,
    multiline_threshold = 20,
    trim_scope = 'outer',
    mode = 'cursor',
  },
  keys = {
    { '<leader>tc', '<cmd>TSContextToggle<cr>', desc = 'Toggle Treesitter Context' },
    {
      '[c',
      function()
        require('treesitter-context').go_to_context(vim.v.count1)
      end,
      desc = 'Go to context',
    },
  },
}
