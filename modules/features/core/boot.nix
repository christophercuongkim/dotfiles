# Bootloader and kernel configuration
#
# Uses systemd-boot for UEFI systems.
# Kernel params:
#   - kvm.enable_virt_at_load=0: Delay KVM virtualization (fixes some AMD issues)
#   - pcie_aspm=off: Disable PCIe power management (improves stability)
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
