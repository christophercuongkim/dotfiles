# Android tooling (adb, fastboot) + SDK environment.
# The SDK itself lives imperatively at ~/Android/Sdk (managed by Flutter /
# sdkmanager); here we provide native adb/fastboot and point tools at it.
#
# NEW-SYSTEM SETUP (manual, one-time — not captured by Nix):
#   1. Native adb/fastboot come from nix-ld + this module. The SDK's own
#      prebuilt binaries only run because `nixos.nix-ld` is imported too.
#   2. Android Studio unpacks cmdline-tools to $ANDROID_HOME/cmdline-tools/{bin,lib},
#      but sdkmanager requires them under a `latest/` subdir. Fix once:
#        cd ~/Android/Sdk/cmdline-tools
#        mkdir -p latest && mv bin lib NOTICE.txt source.properties latest/
#      Verify: ~/Android/Sdk/cmdline-tools/latest/bin/sdkmanager --version
#   3. Accept licenses: flutter doctor --android-licenses
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
