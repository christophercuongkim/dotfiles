# Power profiles daemon
{ ... }:
{
  flake.modules.nixos.power-profiles = {
    services.power-profiles-daemon.enable = true;
  };
}
