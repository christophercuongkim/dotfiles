# Wayland environment variables
{ ... }:
{
  flake.modules.nixos.wayland = {
    environment.variables = {
      XDG_SESSION_TYPE = "wayland";
      QT_QPA_PLATFORM = "wayland";
      MOZ_ENABLE_WAYLAND = "1";
      NIXOS_OZONE_WL = "1";
      GDK_BACKEND = "wayland";
    };
  };
}
