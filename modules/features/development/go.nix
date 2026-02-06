# Go programming language
{ ... }:
{
  flake.modules.nixos.go = { pkgs, ... }: {
    environment.systemPackages = with pkgs; [ go ];
  };
}
