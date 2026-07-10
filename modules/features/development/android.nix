# Android tooling (adb, fastboot)
{ ... }:
{
  flake.modules.nixos.android-tools = { pkgs, ... }: {
    environment.systemPackages = with pkgs; [
      android-tools
    ];
  };
}
