# GTK theme and settings
{ ... }:
{
  flake.modules.nixos.gtk = { pkgs, ... }: {
    environment.systemPackages = with pkgs; [
      adwaita-icon-theme
      gnome-themes-extra
      gsettings-desktop-schemas
      gtk3
      gtk4
    ];
  };

  flake.modules.homeManager.gtk = {
    gtk.enable = true;
  };
}
