# Firmware update daemon
{ ... }:
{
  flake.modules.nixos.firmware = {
    services.fwupd.enable = true;
  };
}
