# Framework laptop udev rules
{ ... }:
{
  flake.modules.nixos.framework-udev = { pkgs, ... }: {
    services.udev.extraRules = ''
      # Wifi power saving off
      ACTION=="add", SUBSYSTEM=="net", KERNEL=="wl*", RUN+="${pkgs.iw}/bin/iw dev %k set power_save off"

      # Camera-specific power management
      ACTION=="add", SUBSYSTEM=="video4linux", ATTR{index}=="0", RUN+="${pkgs.bash}/bin/bash -c 'echo on > /sys$devpath/device/power/control'"
      ACTION=="add", SUBSYSTEM=="usb", ATTRS{idVendor}=="32ac", ATTR{power/control}="on", ATTR{power/autosuspend}="-1"
      ACTION=="add", SUBSYSTEM=="usb", ATTRS{idVendor}=="5986", ATTR{power/control}="on", ATTR{power/autosuspend}="-1"
      ACTION=="add", SUBSYSTEM=="usb", ATTRS{idVendor}=="1c4f", ATTR{power/control}="on", ATTR{power/autosuspend}="-1"
    '';
  };
}
