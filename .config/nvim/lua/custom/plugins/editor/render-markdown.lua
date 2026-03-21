return {
  {
    'MeanderingProgrammer/render-markdown.nvim',
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
        function()
          local m = require 'render-markdown'
          if m.state.enabled then
            m.disable()
          else
            m.enable()
          end
        end,
        desc = 'Toggle Render Markdown',
      },
    },
  },
}
