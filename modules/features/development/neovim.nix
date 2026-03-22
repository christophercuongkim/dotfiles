# Neovim text editor
{ ... }:
{
  flake.modules.nixos.neovim = { pkgs, ... }: {
    environment.systemPackages = with pkgs; [
      neovim
      # Treesitter CLI for parser compilation
      tree-sitter
    ];
  };
}
