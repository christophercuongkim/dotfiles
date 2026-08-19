# Zig programming language
{ ... }:
{
  flake.modules.nixos.zig = { pkgs, ... }: {
    environment.systemPackages = with pkgs; [
      zig
      zls # Zig language server (nvim LSP)
    ];
  };
}
