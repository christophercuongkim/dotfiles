return {
  {
    'MeanderingProgrammer/render-markdown.nvim',
    dependencies = { 'nvim-treesitter/nvim-treesitter' },
    ft = { 'markdown', 'norg', 'rmd', 'org', 'codecompanion' },
    opts = {
      enabled = true,
      render_modes = { 'n', 'c', 't' },
      preset = 'lazy',
      max_file_size = 10.0,
    },
    keys = {
      {
        '<leader>rm',
        '<cmd>RenderMarkdown toggle<cr>',
        desc = 'Toggle Render Markdown',
      },
    },
  },
}
