# Bootloader and kernel configuration
#
# Uses systemd-boot for UEFI systems.
# Kernel params:
#   - kvm.enable_virt_at_load=0: Delay KVM virtualization (fixes some AMD issues)
#   - pcie_aspm=off: Disable PCIe power management (improves stability)
#   - i8042.reset=1: Reset the PS/2 controller on init *and* resume. Without
#     this the internal keyboard can come back from s2idle delivering no
#     interrupts at all (IRQ 1 frozen, /dev/input/event1 silent) -- dead until
#     reboot, while the USB fingerprint reader keeps working because USB
#     re-enumerates. Only an atkbd unbind/bind or a reboot recovers it.
{ ... }:
{
  flake.modules.nixos.boot = {
    boot.loader.systemd-boot.enable = true;
    boot.loader.efi.canTouchEfiVariables = true;
    boot.kernelParams = [
      "kvm.enable_virt_at_load=0"
      "pcie_aspm=off"
      "i8042.reset=1"
    ];
  };
}
