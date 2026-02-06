-- LSP Configuration
-- Uses centralized modules for platform detection, server configs, and keymaps

local platform = require('custom.platform')
local servers = require('custom.configs.lsp.servers')
local lsp_keymaps = require('custom.configs.lsp.keymaps')

return {
  {
    'neovim/nvim-lspconfig',
    dependencies = {
      {
        'mason-org/mason.nvim',
        enabled = platform.use_mason,
        config = true,
      },
      {
        'williamboman/mason-lspconfig.nvim',
        enabled = platform.use_mason,
      },
      {
        'WhoIsSethDaniel/mason-tool-installer.nvim',
        enabled = platform.use_mason,
      },
      { 'j-hui/fidget.nvim', opts = {} },
      { 'folke/neodev.nvim', opts = {} },
      { 'saghen/blink.cmp' },
    },

    config = function()
      -- Setup LspAttach autocmd
      vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true }),
        callback = function(event)
          lsp_keymaps.on_attach(event)
          lsp_keymaps.setup_document_highlight(event)
          lsp_keymaps.setup_server_specifics(event)
        end,
      })

      local capabilities = vim.lsp.protocol.make_client_capabilities()
      local lspconfig = require('lspconfig')

      -- Setup manual server configurations (servers not in lspconfig)
      servers.setup_manual_servers(lspconfig)

      if platform.use_mason then
        -- Non-Nix: Use Mason for LSP server management
        require('mason').setup()

        local ensure_installed = vim.tbl_keys(servers.servers or {})
        vim.list_extend(ensure_installed, servers.mason_tools)

        require('mason-tool-installer').setup { ensure_installed = ensure_installed }

        require('mason-lspconfig').setup {
          handlers = {
            function(server_name)
              -- Skip manually configured servers
              if server_name == 'ty' then
                return
              end

              local server = servers.servers[server_name] or {}
              local blink_caps = require('blink.cmp').get_lsp_capabilities(server.capabilities or {})
              server.capabilities = vim.tbl_deep_extend('force', {}, capabilities, server.capabilities or {}, blink_caps)
              lspconfig[server_name].setup(server)
            end,
          },
        }
      else
        -- Nix: Setup LSPs directly (Nix provides the servers)
        for server_name, server_config in pairs(servers.servers) do
          local blink_caps = require('blink.cmp').get_lsp_capabilities(server_config.capabilities or {})
          server_config.capabilities = vim.tbl_deep_extend(
            'force',
            {},
            capabilities,
            server_config.capabilities or {},
            blink_caps
          )
          lspconfig[server_name].setup(server_config)
        end
      end
    end,
  },
}
