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

      # Debug adapters (DAP)
      delve                     # Go debugger (dlv)
      python3Packages.debugpy   # Python debugger

      # Treesitter dependencies (parser compilation)
      gcc
      gnumake
    ];
  };
}
