# Rofi application launcher
{ ... }:
{
  flake.modules.nixos.rofi = { pkgs, ... }: {
    environment.systemPackages = with pkgs; [
      rofi
    ];
  };
}
