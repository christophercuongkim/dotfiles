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

      # Treesitter dependencies (parser compilation)
      gcc
      gnumake
    ];
  };
}
