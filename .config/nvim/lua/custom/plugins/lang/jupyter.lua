-- Jupyter notebooks: edit .ipynb as plain text (jupytext) and run cells
-- against a real kernel with inline output (molten).
--
-- External dependencies are NOT Mason-installable; they come from:
--   Nix     -- modules/features/development/neovim.nix ships jupytext and
--              imagemagick, and builds neovim with withPython3 so the python
--              remote-plugin host exists at all (the default wrapper disables
--              it).
--   non-Nix -- `pipx install jupytext`, plus a venv at ~/.virtualenvs/neovim
--              holding `pynvim jupyter-client`, which platform.python3_host()
--              picks up. Run `:UpdateRemotePlugins` after creating it.
--
-- Kernels are per-project, not global:
--   uv pip install ipykernel && python -m ipykernel install --user --name <env>

local platform = require('custom.platform')

-- Inline plots need the kitty graphics protocol. Without it molten still runs
-- cells and shows text output, so image.nvim is disabled outright rather than
-- left to fail at draw time.
local images = platform.has_kitty_graphics

return {
  {
    -- Opens .ipynb as markdown, converts back on write. Everything downstream
    -- (treesitter, LSP, conform) then sees an ordinary buffer.
    'GCBallesteros/jupytext.nvim',
    lazy = false,
    opts = {
      style = 'markdown',
      output_extension = 'md',
      force_ft = 'markdown',
    },
  },

  {
    -- Defaults already are backend = 'kitty', processor = 'magick_cli'; the
    -- CLI processor shells out to ImageMagick rather than needing the `magick`
    -- luarock, which is what makes this behave the same on Nix and non-Nix.
    -- The sizing below is molten's recommended setup for its output windows.
    '3rd/image.nvim',
    enabled = images,
    -- image.nvim ships a rockspec, so lazy otherwise tries to build the
    -- `magick` luarock on every startup and fails ("Too many rounds of missing
    -- plugins") -- there is no Lua 5.1/luarocks here and we do not want one.
    -- magick_cli needs none of it.
    build = false,
    opts = {
      max_width = 100,
      max_height = 12,
      max_height_window_percentage = math.huge,
      max_width_window_percentage = math.huge,
      window_overlap_clear_enabled = true,
      window_overlap_clear_ft_ignore = { 'cmp_menu', 'cmp_docs', '' },
      -- We live in tmux; don't paint images into inactive windows.
      tmux_show_only_in_active_window = true,
    },
  },

  {
    'benlubas/molten-nvim',
    version = '^1.0.0',
    -- Not lazy-loaded on purpose. Molten is a python *remote* plugin: its
    -- commands only exist if it is on the runtimepath when
    -- :UpdateRemotePlugins writes the manifest, and they are then defined at
    -- startup from that manifest. Deferring it via `keys`/`ft` leaves the
    -- manifest empty and every :Molten* command reports E492. Loading is cheap
    -- -- no python host is spawned until a Molten command actually runs.
    lazy = false,
    dependencies = images and { '3rd/image.nvim' } or {},
    build = ':UpdateRemotePlugins',
    init = function()
      local host = platform.python3_host()
      if host then
        vim.g.python3_host_prog = host
      end

      vim.g.molten_image_provider = images and 'image.nvim' or 'none'
      vim.g.molten_output_win_max_height = 20
      vim.g.molten_auto_open_output = false
      vim.g.molten_virt_text_output = true
      vim.g.molten_wrap_output = true
    end,
    keys = {
      { '<leader>ji', '<cmd>MoltenInit<cr>', desc = 'Init kernel' },
      { '<leader>jd', '<cmd>MoltenDeinit<cr>', desc = 'Deinit kernel' },
      { '<leader>jl', '<cmd>MoltenEvaluateLine<cr>', desc = 'Evaluate line' },
      { '<leader>je', '<cmd>MoltenEvaluateOperator<cr>', desc = 'Evaluate operator' },
      { '<leader>jr', '<cmd>MoltenReevaluateCell<cr>', desc = 'Re-evaluate cell' },
      { '<leader>jo', '<cmd>MoltenShowOutput<cr>', desc = 'Show output' },
      { '<leader>jh', '<cmd>MoltenHideOutput<cr>', desc = 'Hide output' },
      { '<leader>jn', '<cmd>MoltenNext<cr>', desc = 'Next cell' },
      { '<leader>jp', '<cmd>MoltenPrev<cr>', desc = 'Previous cell' },
      { '<leader>j', ':<C-u>MoltenEvaluateVisual<cr>gv', mode = 'v', desc = 'Evaluate selection' },
    },
  },
}
