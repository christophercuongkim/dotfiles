# LSP servers and formatters for development
{ ... }:
{
  flake.modules.nixos.lsp = { pkgs, ... }: {
    environment.systemPackages = with pkgs; [
      # LSP servers
      lua-language-server
      gopls
      ruff
      ty

      # Formatters
      stylua        # Lua formatter
      golines       # Go line length formatter
      goimports-reviser

      # Linters (for nvim-lint)
      golangci-lint # Go linter
      shellcheck    # Shell script linter

      # Test tools
      gotestsum     # Go test runner (for neotest)

      # Debug adapters (DAP)
      delve                     # Go debugger (dlv)
      python3Packages.debugpy   # Python debugger

      # C/C++ tooling
      clang-tools   # clangd LSP + clang-format
      lldb          # lldb-dap debug adapter
      bear          # generates compile_commands.json from make

      # Treesitter dependencies (parser compilation)
      gcc
      gnumake
    ];
  };
}
