# Bluetooth support with Blueman
{ ... }:
{
  flake.modules.nixos.blueman = { pkgs, ... }: {
    hardware.bluetooth.enable = true;
    hardware.bluetooth.powerOnBoot = true;
    services.blueman.enable = true;
    services.dbus.packages = [ pkgs.blueman ];
  };
}
