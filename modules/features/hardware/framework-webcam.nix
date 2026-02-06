# Framework laptop webcam support
{ ... }:
{
  flake.modules.nixos.framework-webcam = { pkgs, ... }: {
    hardware.enableRedistributableFirmware = true;
    hardware.firmware = with pkgs; [ linux-firmware ];

    boot.kernelModules = [ "uvcvideo" ];

    environment.systemPackages = with pkgs; [
      v4l-utils
      cheese
    ];
  };
}
