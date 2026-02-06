# systemd-resolved DNS configuration
{ ... }:
{
  flake.modules.nixos.resolved = {
    services.resolved.enable = true;
  };
}
