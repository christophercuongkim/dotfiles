return {
  { -- Highlight, edit, and navigate code
    'nvim-treesitter/nvim-treesitter',
    -- The plugin was rewritten: the `main` branch's setup() only reads
    -- `install_dir`. Parser installs, highlighting, folding and indent are no
    -- longer configured via opts — they're driven explicitly below. Pin the
    -- branch so a future update can't silently flip the API out from under us.
    branch = 'main',
    lazy = false,
    build = ':TSUpdate',
    config = function()
      require('nvim-treesitter').setup()

      -- Parsers to keep installed. install() is async and a no-op for parsers
      -- that are already present, so it's cheap to call on every startup.
      -- (dart has no upstream parser — flutter-tools/LSP handles that filetype.)
      require('nvim-treesitter').install {
        'bash', 'c', 'cpp', 'diff', 'go', 'gomod', 'gosum', 'gowork', 'html',
        'java', 'json', 'lua', 'luadoc', 'markdown', 'markdown_inline', 'odin',
        'python', 'query', 'rust', 'toml', 'vim', 'vimdoc', 'yaml', 'zig',
      }

      -- Highlighting, folding and indentation are provided by Neovim itself on
      -- the new branch; enable them per-buffer as filetypes load. vim.treesitter
      -- .start() errors when no parser is installed yet (e.g. first launch,
      -- before install() finishes), so guard it — it'll take effect on reopen.
      vim.api.nvim_create_autocmd('FileType', {
        group = vim.api.nvim_create_augroup('custom-treesitter', { clear = true }),
        callback = function(ev)
          if not pcall(vim.treesitter.start, ev.buf) then
            return
          end
          vim.wo[0][0].foldexpr = 'v:lua.vim.treesitter.foldexpr()'
          -- TS indent is upstream-flagged experimental; vim-sleuth still sets
          -- shiftwidth/expandtab, this only supplies the indent computation.
          vim.bo[ev.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
        end,
      })
    end,
  },
}
