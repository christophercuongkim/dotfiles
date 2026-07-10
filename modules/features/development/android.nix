# Android tooling (adb, fastboot) + SDK environment.
# The SDK itself lives imperatively at ~/Android/Sdk (managed by Flutter /
# sdkmanager); here we provide native adb/fastboot and point tools at it.
topLevel@{ ... }:
let
  username = topLevel.config.username;
  sdkPath = "/home/${username}/Android/Sdk";
in
{
  flake.modules.nixos.android-tools = { pkgs, ... }: {
    environment.systemPackages = with pkgs; [
      android-tools
    ];

    environment.sessionVariables = {
      ANDROID_HOME = sdkPath;
      ANDROID_SDK_ROOT = sdkPath; # legacy name some tools still read
    };
  };
}
