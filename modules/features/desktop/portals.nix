# XDG desktop portals
{ ... }:
{
  flake.modules.nixos.portals = { pkgs, ... }: {
    xdg.portal = {
      enable = true;
      wlr.enable = true;

      extraPortals = with pkgs; [
        xdg-desktop-portal-gtk
        xdg-desktop-portal-hyprland
      ];

      config = {
        common = {
          default = [ "gtk" ];
        };
        hyprland = {
          default = [ "hyprland" "gtk" ];
          "org.freedesktop.impl.portal.Camera" = [ "gtk" ];
        };
      };
    };

    environment.systemPackages = with pkgs; [
      xdg-desktop-portal
      xdg-desktop-portal-gtk
      xdg-desktop-portal-wlr
      xdg-utils
    ];
  };
}
