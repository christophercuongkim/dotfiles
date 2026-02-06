return {
  {
    'NeogitOrg/neogit',
    dependencies = {
      'nvim-lua/plenary.nvim', -- required
      'sindrets/diffview.nvim', -- optional - Diff integration

      'nvim-telescope/telescope.nvim',
    },
    config = function()
      local neogit = require 'neogit'

      neogit.setup {
        -- Hides the hints at the top of the status buffer
        disable_hint = false,
        -- Disables changing the buffer highlights based on where the cursor is.
        disable_context_highlighting = false,
        -- Disables signs for sections/items/hunks
        disable_signs = false,
        -- Changes what mode the Commit Editor starts in. `true` will leave nvim in normal mode, `false` will change nvim to
        -- insert mode, and `"auto"` will change nvim to insert mode IF the commit message is empty, otherwise leaving it in
        -- normal mode.
        disable_insert_on_commit = 'auto',
        -- When enabled, will watch the `.git/` directory for changes and refresh the status buffer in response to filesystem
        -- events.
        filewatcher = {
          interval = 1000,
          enabled = true,
        },
        -- "ascii"   is the graph the git CLI generates
        -- "unicode" is the graph like https://github.com/rbong/vim-flog
        -- "kitty"   is the graph like https://github.com/isakbm/gitgraph.nvim - use https://github.com/rbong/flog-symbols if you don't use Kitty
        graph_style = 'ascii',
        -- Show relative date by default. When set, use `strftime` to display dates
        commit_date_format = '%Y-%m-%d',
        log_date_format = '%Y-%m-%d',
        -- Used to generate URL's for branch popup action "pull request".
        git_services = {
          ['github.com'] = 'https://github.com/${owner}/${repository}/compare/${branch_name}?expand=1',
          ['bitbucket.org'] = 'https://bitbucket.org/${owner}/${repository}/pull-requests/new?source=${branch_name}&t=1',
          ['gitlab.com'] = 'https://gitlab.com/${owner}/${repository}/merge_requests/new?merge_request[source_branch]=${branch_name}',
          ['azure.com'] = 'https://dev.azure.com/${owner}/_git/${repository}/pullrequestcreate?sourceRef=${branch_name}&targetRef=${target}',
        },
        -- Allows a different telescope sorter. Defaults to 'fuzzy_with_index_bias'. The example below will use the native fzf
        -- sorter instead. By default, this function returns `nil`.
        telescope_sorter = function()
          return require('telescope').extensions.fzf.native_fzf_sorter()
        end,
        -- Persist the values of switches/options within and across sessions
        remember_settings = true,
        -- Scope persisted settings on a per-project basis
        use_per_project_settings = true,
        -- Table of settings to never persist. Uses format "Filetype--cli-value"
        ignored_settings = {
          'NeogitPushPopup--force-with-lease',
          'NeogitPushPopup--force',
          'NeogitPullPopup--rebase',
          'NeogitCommitPopup--allow-empty',
          'NeogitRevertPopup--no-edit',
        },
        -- Configure highlight group features
        highlight = {
          italic = true,
          bold = true,
          underline = true,
        },
        -- Set to false if you want to be responsible for creating _ALL_ keymappings
        use_default_keymaps = true,
        -- Neogit refreshes its internal state after specific events, which can be expensive depending on the repository size.
        -- Disabling `auto_refresh` will make it so you have to manually refresh the status after you open it.
        auto_refresh = true,
        -- Value used for `--sort` option for `git branch` command
        -- By default, branches will be sorted by commit date descending
        -- Flag description: https://git-scm.com/docs/git-branch#Documentation/git-branch.txt---sortltkeygt
        -- Sorting keys: https://git-scm.com/docs/git-for-each-ref#_options
        sort_branches = '-committerdate',
        -- Default for new branch name prompts
        initial_branch_name = 'c.kim/',
        -- Change the default way of opening neogit
        kind = 'floating',
        -- Disable line numbers
        disable_line_numbers = true,
        -- Disable relative line numbers
        disable_relative_line_numbers = true,
        -- The time after which an output console is shown for slow running commands
        console_timeout = 2000,
        -- Automatically show console if a command takes more than console_timeout milliseconds
        auto_show_console = true,
        -- Automatically close the console if the process exits with a 0 (success) status
        auto_close_console = true,
        notification_icon = '󰊢',
        signs = {
          -- { CLOSED, OPENED }
          hunk = { '', '' },
          item = { '>', 'v' },
          section = { '>', 'v' },
        },
        -- Each Integration is auto-detected through plugin presence, however, it can be disabled by setting to `false`
        integrations = {
          -- If enabled, use telescope for menu selection rather than vim.ui.select.
          -- Allows multi-select and some things that vim.ui.select doesn't.
          telescope = true,
          -- Neogit only provides inline diffs. If you want a more traditional way to look at diffs, you can use `diffview`.
          -- The diffview integration enables the diff popup.
          --
          -- Requires you to have `sindrets/diffview.nvim` installed.
          diffview = true,

          -- If enabled, uses fzf-lua for menu selection. If the telescope integration
          -- is also selected then telescope is used instead
          -- Requires you to have `ibhagwan/fzf-lua` installed.
          fzf_lua = false,

          -- If enabled, uses mini.pick for menu selection. If the telescope integration
          -- is also selected then telescope is used instead
          -- Requires you to have `echasnovski/mini.pick` installed.
          mini_pick = false,
        },
      }
      vim.keymap.set('n', '<leader>ngo', neogit.open, { desc = 'Open Neogit', silent = true, noremap = true })
      vim.keymap.set('n', '<leader>ngc', ':Neogit commit<CR>', { desc = 'Git: commit', silent = true, noremap = true })
      vim.keymap.set('n', '<leader>ngp', ':Neogit pull<CR>', { desc = 'Git: pull', silent = true, noremap = true })
      vim.keymap.set('n', '<leader>ngP', ':Neogit push<CR>', { desc = 'Git: push', silent = true, noremap = true })
      vim.keymap.set('n', '<leader>ngb', ':Telescope git_branches<CR>', { desc = 'Git: branch', silent = true, noremap = true })
    end,
  },
}
