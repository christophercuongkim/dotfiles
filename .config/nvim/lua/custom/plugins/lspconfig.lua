return {
  {
    'neovim/nvim-lspconfig',
    dependencies = {
      {
        'mason-org/mason.nvim',
        enabled = vim.fn.executable('nix-shell') == 0,
        config = true
      },
      {
        'williamboman/mason-lspconfig.nvim',
        enabled = vim.fn.executable('nix-shell') == 0
      },
      {
        'WhoIsSethDaniel/mason-tool-installer.nvim',
        enabled = vim.fn.executable('nix-shell') == 0
      },
      { 'j-hui/fidget.nvim', opts = {} },
      { 'folke/neodev.nvim', opts = {} },
      { 'saghen/blink.cmp' },
    },
    opts = {
      servers = {
        dartls = {},

        lua_ls = {
          settings = {
            Lua = {
              completion = {
                callSnippet = 'Replace',
              },
              diagnostics = { disable = { 'missing-fields' } },
            },
          },
        },

        gopls = {
          settings = {
            gopls = {
              completeUnimported = true,
              usePlaceholders = true,
              analyses = {
                unusedparams = true,
              },
            },
          },
        },

        ty = {
          settings = {
            ty = {
              diagnosticMode = 'openFilesOnly',
              inlayHints = {
                variableTypes = true,
                parameterNames = true,
              },
            },
          },
        },

        ruff = {
          settings = {
            ruff = {
              lineLength = 88,
              fixAll = true,
              organizeImports = true,
              lint = {
                enable = true,
              },
              codeAction = {
                fixViolation = {
                  enable = false,
                },
              },
              format = {
                preview = true,
              },
            },
          },
        },
      },
    },

    config = function(_, opts)
      vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true }),
        callback = function(event)
          local map = function(keys, func, desc)
            vim.keymap.set('n', keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
          end

          map('gd', require('telescope.builtin').lsp_definitions, '[G]oto [D]efinition')
          map('gr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')
          map('gI', require('telescope.builtin').lsp_implementations, '[G]oto [I]mplementation')
          map('<leader>D', require('telescope.builtin').lsp_type_definitions, 'Type [D]efinition')
          map('<leader>ds', require('telescope.builtin').lsp_document_symbols, '[D]ocument [S]ymbols')
          map('<leader>ws', require('telescope.builtin').lsp_dynamic_workspace_symbols, '[W]orkspace [S]ymbols')
          map('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
          map('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction')
          map('K', vim.lsp.buf.hover, 'Hover Documentation')
          map('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')

          local client = vim.lsp.get_client_by_id(event.data.client_id)
          if client and client.server_capabilities.documentHighlightProvider then
            local highlight_augroup = vim.api.nvim_create_augroup('kickstart-lsp-highlight', { clear = false })
            vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
              buffer = event.buf,
              group = highlight_augroup,
              callback = vim.lsp.buf.document_highlight,
            })
            vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
              buffer = event.buf,
              group = highlight_augroup,
              callback = vim.lsp.buf.clear_references,
            })
            vim.api.nvim_create_autocmd('LspDetach', {
              group = vim.api.nvim_create_augroup('kickstart-lsp-detach', { clear = true }),
              callback = function(event2)
                vim.lsp.buf.clear_references()
                vim.api.nvim_clear_autocmds { group = 'kickstart-lsp-highlight', buffer = event2.buf }
              end,
            })
          end

          if client and client.server_capabilities.inlayHintProvider and vim.lsp.inlay_hint then
            map('<leader>th', function()
              vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
            end, '[T]oggle Inlay [H]ints')
          end

          if client.name == 'ruff' then
            client.server_capabilities.hoverProvider = false
          end
        end,
      })

      local capabilities = vim.lsp.protocol.make_client_capabilities()
      local is_nixos = vim.fn.executable('nix-shell') == 1
      local lspconfig = require('lspconfig')

      -- Manual ty setup (not in lspconfig yet)
      local configs = require('lspconfig.configs')
      if not configs.ty then
        configs.ty = {
          default_config = {
            cmd = { 'ty', 'server' }, -- Changed from 'lsp' to 'server'
            filetypes = { 'python' },
            root_dir = lspconfig.util.root_pattern('pyproject.toml', '.git'),
            settings = {},
          },
        }
      end

      if not is_nixos then
        -- Non-NixOS: Use Mason
        require('mason').setup()

        local ensure_installed = vim.tbl_keys(opts.servers or {})
        vim.list_extend(ensure_installed, { 'stylua' })

        require('mason-tool-installer').setup { ensure_installed = ensure_installed }

        require('mason-lspconfig').setup {
          handlers = {
            function(server_name)
              -- Skip ty - we handle it manually
              if server_name == 'ty' then return end

              local server = opts.servers[server_name] or {}
              local blink_caps = require('blink.cmp').get_lsp_capabilities(server.capabilities or {})
              server.capabilities = vim.tbl_deep_extend('force', {}, capabilities, server.capabilities or {}, blink_caps)
              require('lspconfig')[server_name].setup(server)
            end,
          },
        }
      else
        -- NixOS: Setup LSPs directly without Mason
        for server_name, server_config in pairs(opts.servers) do
          local blink_caps = require('blink.cmp').get_lsp_capabilities(server_config.capabilities or {})
          server_config.capabilities = vim.tbl_deep_extend('force', {}, capabilities, server_config.capabilities or {},
            blink_caps)
          lspconfig[server_name].setup(server_config)
        end
      end
    end,
  },
}
