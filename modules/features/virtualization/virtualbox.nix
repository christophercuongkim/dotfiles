# VirtualBox hypervisor
{ ... }:
{
  flake.modules.nixos.virtualbox = {
    virtualisation.virtualbox.host.enable = true;
    virtualisation.virtualbox.host.enableExtensionPack = true;
  };
}
