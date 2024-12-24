return {
  {
    'epwalsh/obsidian.nvim',
    version = '*', -- recommended, use latest release instead of latest commit
    lazy = true,
    ft = 'markdown',

    dependencies = {
      -- Required.
      'nvim-lua/plenary.nvim',
      'nvim-telescope/telescope.nvim',
    },
    opts = {
      workspaces = {
        {
          name = 'personal',
          path = '~/notes/chris_notes',
        },
      },
      notes_subdir = 'notes',
      log_level = vim.log.levels.INFO,
      mappings = {
        -- Overrides the 'gf' mapping to work on markdown/wiki links within your vault.
        ['gf'] = {
          action = function()
            return require('obsidian').util.gf_passthrough()
          end,
          opts = { noremap = false, expr = true, buffer = true },
        },
        -- Toggle check-boxes.
        ['<leader>ch'] = {
          action = function()
            return require('obsidian').util.toggle_checkbox()
          end,
          opts = { buffer = true },
        },
        -- Smart action depending on context, either follow link or toggle checkbox.
        ['<cr>'] = {
          action = function()
            return require('obsidian').util.smart_action()
          end,
          opts = { buffer = true, expr = true },
        },
      },
      new_notes_location = 'notes_subdir',
      -- Optional, customize how note IDs are generated given an optional title.
      ---@param title string|?
      ---@return string
      note_id_func = function(title)
        -- Create note IDs in a Zettelkasten format with a timestamp and a suffix.
        -- In this case a note with the title 'My new note' will be given an ID that looks
        -- like '1657296016-my-new-note', and therefore the file name '1657296016-my-new-note.md'
        local suffix = ''
        if title ~= nil then
          -- If title is given, transform it into valid file name.
          suffix = title:gsub(' ', '_'):gsub('[^A-Za-z0-9-]', ''):lower()
        else
          -- If title is nil, just add 4 random uppercase letters to the suffix.
          for _ = 1, 4 do
            suffix = suffix .. string.char(math.random(65, 90))
          end
        end
        local date_fmtd = os.date('%Y%m%d%H%M', os.time())
        return tostring(date_fmtd) .. '_' .. suffix
      end,
      -- Optional, for templates (see below).
      templates = {
        folder = 'templates',
        date_format = '%Y%m%d',
        time_format = '%H%M',
        -- A map for custom variables, the key should be the variable and the value a function
        substitutions = {},
      },
    },
    config = function(_, opts)
      obsidian = require('obsidian').setup(opts)
      vim.keymap.set('n', '<leader>oqs', '<cmd>ObsidianQuickSwitch<CR>', { desc = 'Open ObsidianQuickSwitch', silent = true, noremap = true })
      vim.keymap.set('n', '<leader>ont', '<cmd>ObsidianNewFromTemplate<CR>', { desc = 'Open new note from template', silent = true, noremap = true })
      vim.keymap.set('n', '<leader>ol', '<cmd>ObsidianLinks<CR>', { desc = 'Open Links', silent = true, noremap = true })
      vim.keymap.set('n', '<leader>obl', '<cmd>ObsidianBacklinks<CR>', { desc = 'Open ObsidianQuickSwitch', silent = true, noremap = true })
    end,
  },
}
