return {
  {
    'olexsmir/gopher.nvim',
    ft = 'go',
    -- branch = "develop", -- if you want develop branch
    -- keep in mind, it might break everything
    dependencies = {
      'nvim-lua/plenary.nvim',
      'nvim-treesitter/nvim-treesitter',
      'mfussenegger/nvim-dap', -- (optional) only if you use `gopher.dap`
    },
    ---@type gopher.Config
    opts = {
      commands = {
        go = 'go',
        gomodifytags = 'gomodifytags',
        gotests = 'gotests',
        impl = 'impl',
        iferr = 'iferr',
        dlv = 'dlv',
      },
      gotests = {
        -- gotests doesn't have template named "default" so this plugin uses "default" to set the default template
        template = 'default',
        -- path to a directory containing custom test code templates
        template_dir = nil,
        -- switch table tests from using slice to map (with test name for the key)
        -- works only with gotests installed from develop branch
        named = false,
      },
      gotag = {
        transform = 'snakecase',
      },
    },
    config = function(_, opts)
      require('gopher').setup(opts)

      -- Use spaces instead of tabs for Go files
      vim.api.nvim_create_autocmd('FileType', {
        pattern = 'go',
        callback = function()
          vim.opt_local.expandtab = true
          vim.opt_local.shiftwidth = 4
          vim.opt_local.tabstop = 4
        end,
      })
      vim.keymap.set('n', '<leader>gsj', '<cmd> GoTagAdd json <cr>', { desc = '[G]o [S]truct tags: json' })
      vim.keymap.set('n', '<leader>gsy', '<cmd> GoTagAdd yaml <cr>', { desc = '[G]o [S]truct tags: yaml' })
      vim.keymap.set('n', '<leader>gst', '<cmd> GoTagAdd toml <cr>', { desc = '[G]o [S]truct tags: toml' })
      vim.keymap.set('n', '<leader>gc', '<cmd> GoCmt <cr>', { desc = '[G]o [C]omment boilerplate' })
      vim.keymap.set('n', '<leader>ge', '<cmd> GoIfErr <cr>', { desc = '[G]o if [E]rr snippet' })
    end,
  },
}
