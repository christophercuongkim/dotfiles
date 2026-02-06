-- LSP Server configurations
-- Centralized server settings for all language servers

local M = {}

-- Server configurations
M.servers = {
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
}

-- Tools to install via Mason (only used on non-Nix systems)
M.mason_tools = {
  'stylua',
}

-- Manual LSP configurations (servers not in lspconfig)
function M.setup_manual_servers(lspconfig)
  local configs = require('lspconfig.configs')

  -- ty (Python type checker) - not in lspconfig yet
  if not configs.ty then
    configs.ty = {
      default_config = {
        cmd = { 'ty', 'server' },
        filetypes = { 'python' },
        root_dir = lspconfig.util.root_pattern('pyproject.toml', '.git'),
        settings = {},
      },
    }
  end
end

return M
