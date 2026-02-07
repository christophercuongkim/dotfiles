-- Unified test runner
-- NOTE: Disabled due to treesitter query incompatibility with current Go parser
-- The neotest lib uses "statement_list" which no longer exists in Go grammar
-- Re-enable when neotest is updated
return {
  'nvim-neotest/neotest',
  enabled = false,
  lazy = false,
  dependencies = {
    'nvim-neotest/nvim-nio',
    'nvim-lua/plenary.nvim',
    'antoinemadec/FixCursorHold.nvim',
    'nvim-treesitter/nvim-treesitter',
    -- Test adapters
    { 'fredrikaverpil/neotest-golang', lazy = false },
    { 'nvim-neotest/neotest-python', lazy = false },
  },
  keys = {
    { '<leader>tt', function() require('neotest').run.run() end, desc = 'Run nearest test' },
    { '<leader>tf', function() require('neotest').run.run(vim.fn.expand('%')) end, desc = 'Run file tests' },
    { '<leader>ts', function() require('neotest').summary.toggle() end, desc = 'Toggle test summary' },
    { '<leader>to', function() require('neotest').output.open({ enter = true }) end, desc = 'Show test output' },
    { '<leader>tO', function() require('neotest').output_panel.toggle() end, desc = 'Toggle output panel' },
    { '<leader>tS', function() require('neotest').run.stop() end, desc = 'Stop test' },
    { '[t', function() require('neotest').jump.prev({ status = 'failed' }) end, desc = 'Previous failed test' },
    { ']t', function() require('neotest').jump.next({ status = 'failed' }) end, desc = 'Next failed test' },
  },
  config = function()
    local neotest = require('neotest')
    neotest.setup({
      adapters = {
        require('neotest-golang'),
        require('neotest-python'),
      },
    })
  end,
}
