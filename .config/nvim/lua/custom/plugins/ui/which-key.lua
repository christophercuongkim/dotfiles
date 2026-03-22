return {
  { -- Useful plugin to show you pending keybinds.
    'folke/which-key.nvim',
    event = 'VimEnter', -- Sets the loading event to 'VimEnter'
    config = function() -- This is the function that runs, AFTER loading
      require('which-key').setup()

      -- Document existing key chains
      require('which-key').add {
        { '<leader>a', group = '[A]erial' },
        { '<leader>b', group = 'Data[B]ase' },
        { '<leader>c', group = '[C]ode' },
        { '<leader>d', group = '[D]ocument' },
        { '<leader>e', group = '[E]rror' },
        { '<leader>f', group = '[F]ormat' },
        { '<leader>g', group = '[G]o' },
        { '<leader>h', group = 'Git [H]unk', mode = { 'n', 'v' } },
        { '<leader>l', group = '[L]int' },
        { '<leader>m', group = '[M]ark' },
        { '<leader>n', group = '[N]avigation' },
        { '<leader>o', group = '[O]bsidian' },
        { '<leader>p', group = '[P]revious' },
        { '<leader>q', group = '[Q]uickfix' },
        { '<leader>r', group = '[R]ename' },
        { '<leader>s', group = '[S]earch' },
        { '<leader>t', group = '[T]oggle' },
        { '<leader>u', group = '[U]ndo' },
        { '<leader>w', group = '[W]orkspace' },
        { '<leader>x', group = '[X] Trouble' },
        { '<leader>R', group = '[R]eplace (Spectre)' },
        -- Nested groups
        { '<leader>dg', group = '[D]ebug [G]o' },
        { '<leader>dp', group = '[D]ebug [P]ython' },
        { '<leader>gs', group = '[G]o [S]truct tags' },
        { '<leader>ng', group = '[N]eo[G]it' },
        { '<leader>ob', group = '[O]bsidian [B]acklinks' },
        { '<leader>on', group = '[O]bsidian [N]ew' },
        { '<leader>oq', group = '[O]bsidian [Q]uick' },
      }
    end,
  },
}
