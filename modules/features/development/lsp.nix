# LSP servers for development
{ ... }:
{
  flake.modules.nixos.lsp = { pkgs, ... }: {
    environment.systemPackages = with pkgs; [
      lua-language-server
      gopls
      golines
      goimports-reviser
      ruff
      ty
    ];
  };
}
