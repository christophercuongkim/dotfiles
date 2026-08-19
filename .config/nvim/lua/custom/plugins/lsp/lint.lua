-- Async linting with nvim-lint
return {
  'mfussenegger/nvim-lint',
  event = { 'BufReadPost', 'BufWritePost' },
  config = function()
    local lint = require('lint')

    lint.linters_by_ft = {
      -- python omitted: the ruff LSP (servers.lua) already lints with fixAll,
      -- so running ruff via nvim-lint too would double the diagnostics.
      go = { 'golangcilint' },
      sh = { 'shellcheck' },
      bash = { 'shellcheck' },
    }

    -- Create autocommand to trigger linting
    vim.api.nvim_create_autocmd({ 'BufEnter', 'BufWritePost', 'InsertLeave' }, {
      group = vim.api.nvim_create_augroup('nvim-lint', { clear = true }),
      callback = function()
        lint.try_lint()
      end,
    })

    -- Keymap to manually trigger linting
    vim.keymap.set('n', '<leader>l', function()
      lint.try_lint()
    end, { desc = '[L]int current file' })
  end,
}
