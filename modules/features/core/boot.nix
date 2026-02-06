# Bootloader configuration
{ ... }:
{
  flake.modules.nixos.boot = {
    boot.loader.systemd-boot.enable = true;
    boot.loader.efi.canTouchEfiVariables = true;
    boot.kernelParams = [
      "kvm.enable_virt_at_load=0"
      "pcie_aspm=off"
    ];
  };
}
