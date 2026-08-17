-- LSP Server configurations
-- Centralized server settings for all language servers

local M = {}

-- Server configurations
M.servers = {
  dartls = {},

  -- Odin language server. Uses nvim-lspconfig's default `ols` config; the
  -- ols/odin binaries come from the Nix `odin` module, not Mason.
  ols = {},

  clangd = {
    cmd = { 'clangd', '--background-index', '--clang-tidy', '--header-insertion=iwyu' },
    filetypes = { 'c', 'cpp', 'objc', 'objcpp' },
    root_markers = { 'compile_commands.json', '.clangd', 'Makefile', 'CMakeLists.txt', '.git' },
  },

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
    cmd = { 'ty', 'server' },
    filetypes = { 'python' },
    root_markers = { 'pyproject.toml', '.git' },
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

return M
