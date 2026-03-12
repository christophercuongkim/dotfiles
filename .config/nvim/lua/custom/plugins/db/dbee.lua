return {
  {
    'kndndrj/nvim-dbee',
    dependencies = {
      'MunifTanjim/nui.nvim',
    },
    build = function()
      -- Install tries to automatically detect the install method.
      -- if it fails, try calling it with one of these parameters:
      --    "curl", "wget", "bitsadmin", "go"
      require('dbee').install()
    end,
    config = function()
      local tools = require 'dbee.layouts.tools'
      local api_ui = require 'dbee.api.ui'

      -- Custom layout without editor pane (no welcome.sql)
      local NoEditorLayout = {}

      function NoEditorLayout:new(opts)
        opts = opts or {}
        local o = {
          drawer_width = opts.drawer_width or 40,
          result_height = opts.result_height or 20,
          call_log_height = opts.call_log_height or 20,
          egg = nil,
        }
        setmetatable(o, self)
        self.__index = self
        return o
      end

      function NoEditorLayout:open()
        if self.egg then
          return
        end
        self.egg = tools.save()

        local original_win = vim.api.nvim_get_current_win()

        -- Drawer on the left
        vim.cmd('topleft ' .. self.drawer_width .. 'vsplit')
        local drawer_win = vim.api.nvim_get_current_win()
        api_ui.drawer_show(drawer_win)

        -- Call log at the bottom left
        vim.cmd('botright ' .. self.result_height .. 'split')
        local call_log_win = vim.api.nvim_get_current_win()
        api_ui.call_log_show(call_log_win)

        -- Result to the right of call log
        vim.cmd 'vertical rightbelow split'
        local result_win = vim.api.nvim_get_current_win()
        api_ui.result_show(result_win)

        -- Resize call log to match drawer width
        vim.api.nvim_win_set_width(call_log_win, self.drawer_width)

        vim.api.nvim_set_current_win(original_win)
      end

      function NoEditorLayout:close()
        if not self.egg then
          return
        end
        tools.restore(self.egg)
        self.egg = nil
      end

      function NoEditorLayout:is_open()
        return self.egg ~= nil
      end

      function NoEditorLayout:reset()
        -- No-op: custom layout handles state internally
      end

      require('dbee').setup {
        window_layout = NoEditorLayout:new {
          drawer_width = 40,
          result_height = 20,
        },
      }
    end,
    keys = {
      {
        '<leader>bt',
        function()
          require('dbee').toggle()
        end,
        desc = 'DB: Toggle dbee',
      },

      -- Execute current line
      {
        '<leader>be',
        function()
          require('dbee').execute(vim.api.nvim_get_current_line())
        end,
        desc = 'DB: Execute line',
      },

      -- Execute visual selection
      {
        '<leader>be',
        function()
          local lines = vim.fn.getregion(vim.fn.getpos 'v', vim.fn.getpos '.', { type = vim.fn.mode() })
          require('dbee').execute(table.concat(lines, '\n'))
        end,
        desc = 'DB: Execute selection',
        mode = 'v',
      },

      -- Execute entire buffer
      {
        '<leader>bE',
        function()
          local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
          require('dbee').execute(table.concat(lines, '\n'))
        end,
        desc = 'DB: Execute buffer',
      },

      -- Store result
      {
        '<leader>bs',
        function()
          require('dbee').store('csv', 'file')
        end,
        desc = 'DB: Save result to file',
      },
      {
        '<leader>by',
        function()
          require('dbee').store('csv', 'yank')
        end,
        desc = 'DB: Yank result',
      },
    },
  },
}
