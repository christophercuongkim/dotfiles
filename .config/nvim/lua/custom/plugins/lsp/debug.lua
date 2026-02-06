-- Debug Adapter Protocol (DAP) configuration
-- Supports Go (delve) and Python (debugpy)

local platform = require('custom.platform')

return {
  'mfussenegger/nvim-dap',
  dependencies = {
    -- Beautiful debugger UI
    'rcarriga/nvim-dap-ui',
    'nvim-neotest/nvim-nio',

    -- Mason for non-Nix systems
    {
      'williamboman/mason.nvim',
      enabled = platform.use_mason,
    },
    {
      'jay-babu/mason-nvim-dap.nvim',
      enabled = platform.use_mason,
    },

    -- Language-specific extensions
    'leoluz/nvim-dap-go',
    'mfussenegger/nvim-dap-python',
  },

  keys = {
    { '<leader>dc', desc = 'Debug: Start/Continue' },
    { '<leader>db', desc = 'Debug: Toggle Breakpoint' },
  },

  config = function()
    local dap = require('dap')
    local dapui = require('dapui')

    -- Setup Mason on non-Nix systems
    if platform.use_mason then
      require('mason-nvim-dap').setup({
        automatic_installation = true,
        handlers = {},
        ensure_installed = {
          'delve',
          'debugpy',
        },
      })
    else
      -- NixOS: Configure debug adapters manually
      -- Go (delve)
      dap.adapters.delve = {
        type = 'server',
        port = '${port}',
        executable = {
          command = 'dlv',
          args = { 'dap', '-l', '127.0.0.1:${port}' },
        },
      }

      dap.configurations.go = {
        {
          type = 'delve',
          name = 'Debug',
          request = 'launch',
          program = '${file}',
        },
        {
          type = 'delve',
          name = 'Debug Package',
          request = 'launch',
          program = '${fileDirname}',
        },
        {
          type = 'delve',
          name = 'Debug test',
          request = 'launch',
          mode = 'test',
          program = '${file}',
        },
        {
          type = 'delve',
          name = 'Debug test (go.mod)',
          request = 'launch',
          mode = 'test',
          program = './${relativeFileDirname}',
        },
      }

      -- Python (debugpy) - use debugpy-adapter binary on NixOS
      dap.adapters.python = function(cb, config)
        if config.request == 'attach' then
          local port = (config.connect or config).port
          local host = (config.connect or config).host or '127.0.0.1'
          cb({
            type = 'server',
            port = assert(port, '`connect.port` is required for a python `attach` configuration'),
            host = host,
            options = {
              source_filetype = 'python',
            },
          })
        else
          cb({
            type = 'executable',
            command = 'debugpy-adapter',
            args = {},
            options = {
              source_filetype = 'python',
            },
          })
        end
      end

      dap.configurations.python = {
        {
          type = 'python',
          request = 'launch',
          name = 'Launch file',
          program = '${file}',
          pythonPath = function()
            -- Use activated virtualenv or fall back to system python
            local venv = os.getenv('VIRTUAL_ENV')
            if venv then
              return venv .. '/bin/python'
            end
            return 'python'
          end,
        },
        {
          type = 'python',
          request = 'launch',
          name = 'Launch file with arguments',
          program = '${file}',
          args = function()
            local args_string = vim.fn.input('Arguments: ')
            return vim.split(args_string, ' +')
          end,
          pythonPath = function()
            local venv = os.getenv('VIRTUAL_ENV')
            if venv then
              return venv .. '/bin/python'
            end
            return 'python'
          end,
        },
        {
          type = 'python',
          request = 'attach',
          name = 'Attach remote',
          connect = function()
            local host = vim.fn.input('Host [127.0.0.1]: ')
            host = host ~= '' and host or '127.0.0.1'
            local port = tonumber(vim.fn.input('Port [5678]: ')) or 5678
            return { host = host, port = port }
          end,
        },
      }
    end

    -- Keymaps
    vim.keymap.set('n', '<leader>dc', dap.continue, { desc = 'Debug: Start/Continue' })
    vim.keymap.set('n', '<leader>di', dap.step_into, { desc = 'Debug: Step Into' })
    vim.keymap.set('n', '<leader>do', dap.step_over, { desc = 'Debug: Step Over' })
    vim.keymap.set('n', '<leader>du', dap.step_out, { desc = 'Debug: Step Out' })
    vim.keymap.set('n', '<leader>db', dap.toggle_breakpoint, { desc = 'Debug: Toggle Breakpoint' })
    vim.keymap.set('n', '<leader>dB', function()
      dap.set_breakpoint(vim.fn.input('Breakpoint condition: '))
    end, { desc = 'Debug: Conditional Breakpoint' })
    vim.keymap.set('n', '<leader>dl', function()
      dap.set_breakpoint(nil, nil, vim.fn.input('Log point message: '))
    end, { desc = 'Debug: Log Point' })
    vim.keymap.set('n', '<leader>dr', dap.repl.open, { desc = 'Debug: Open REPL' })
    vim.keymap.set('n', '<leader>dx', dap.terminate, { desc = 'Debug: Terminate' })

    -- DAP UI setup
    dapui.setup({
      icons = { expanded = '▾', collapsed = '▸', current_frame = '*' },
      controls = {
        icons = {
          pause = '⏸',
          play = '▶',
          step_into = '⏎',
          step_over = '⏭',
          step_out = '⏮',
          step_back = 'b',
          run_last = '▶▶',
          terminate = '⏹',
          disconnect = '⏏',
        },
      },
    })

    vim.keymap.set('n', '<leader>dd', dapui.toggle, { desc = 'Debug: Toggle UI' })
    vim.keymap.set('n', '<leader>de', dapui.eval, { desc = 'Debug: Eval under cursor' })
    vim.keymap.set('v', '<leader>de', dapui.eval, { desc = 'Debug: Eval selection' })

    -- Auto open/close UI
    dap.listeners.after.event_initialized['dapui_config'] = dapui.open
    dap.listeners.before.event_terminated['dapui_config'] = dapui.close
    dap.listeners.before.event_exited['dapui_config'] = dapui.close

    -- Go-specific setup (nvim-dap-go provides better defaults)
    require('dap-go').setup({
      delve = {
        detached = vim.fn.has('win32') == 0,
      },
    })

    vim.keymap.set('n', '<leader>dgt', function()
      require('dap-go').debug_test()
    end, { desc = 'Debug: Go Test' })
    vim.keymap.set('n', '<leader>dgl', function()
      require('dap-go').debug_last_test()
    end, { desc = 'Debug: Go Last Test' })

    -- Python-specific setup
    if platform.use_mason then
      -- Non-Nix: Use nvim-dap-python with Mason-installed debugpy
      local dap_python = require('dap-python')
      dap_python.setup('python')

      vim.keymap.set('n', '<leader>dpt', function()
        dap_python.test_method()
      end, { desc = 'Debug: Python Test Method' })
      vim.keymap.set('n', '<leader>dpc', function()
        dap_python.test_class()
      end, { desc = 'Debug: Python Test Class' })
      vim.keymap.set('v', '<leader>dps', function()
        dap_python.debug_selection()
      end, { desc = 'Debug: Python Selection' })
    end
    -- On NixOS: Python adapter and configs are set up manually above
    -- Use <leader>dc to start debugging Python files
  end,
}
