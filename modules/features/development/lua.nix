# Lua programming language
{ ... }:
{
  flake.modules.nixos.lua = { pkgs, ... }: {
    environment.systemPackages = with pkgs; [
      lua
      luarocks
    ];
  };
}
