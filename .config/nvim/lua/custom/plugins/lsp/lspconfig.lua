-- LSP Configuration
-- Uses vim.lsp.config (Neovim 0.11+) with nvim-lspconfig for server configs

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
      -- lazydev configures lua_ls for Neovim/plugin development (replaces the
      -- archived neodev.nvim); the blink source is registered in blink.lua.
      { 'folke/lazydev.nvim', ft = 'lua', opts = {} },
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

      -- Get capabilities from blink.cmp
      local capabilities = require('blink.cmp').get_lsp_capabilities()

      -- Configure and enable each LSP server using vim.lsp.config (Neovim 0.11+)
      for server_name, server_config in pairs(servers.servers) do
        local config = vim.tbl_deep_extend('force', {
          capabilities = capabilities,
        }, server_config)

        vim.lsp.config(server_name, config)
        vim.lsp.enable(server_name)
      end

      -- Mason setup for non-Nix systems
      if platform.use_mason then
        require('mason').setup()

        local ensure_installed = vim.tbl_keys(servers.servers or {})
        vim.list_extend(ensure_installed, servers.mason_tools)

        require('mason-tool-installer').setup { ensure_installed = ensure_installed }
        require('mason-lspconfig').setup {}
      end
    end,
  },
}
