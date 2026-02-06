# Terminal emulators
# TEMPORARILY DISABLED - home-manager contributions
{ ... }:
{
  flake.modules.nixos.terminals = { pkgs, ... }: {
    environment.systemPackages = with pkgs; [
      kitty
      ghostty
    ];
  };
}
