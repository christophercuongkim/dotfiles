# Hyprlock lock screen
{ ... }:
{
  flake.modules.nixos.hyprlock = { pkgs, ... }: {
    security.pam.services.hyprlock = {};

    environment.systemPackages = with pkgs; [
      hyprlock
    ];
  };
}
