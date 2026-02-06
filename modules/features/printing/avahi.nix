# Avahi mDNS/printer discovery
{ ... }:
{
  flake.modules.nixos.avahi = {
    services.avahi = {
      enable = true;
      nssmdns4 = true;
      openFirewall = true;
    };
  };
}
