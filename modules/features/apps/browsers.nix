# Chromium-based browsers (Brave, Chrome)
{ ... }:
{
  flake.modules.nixos.browsers = { pkgs, ... }: {
    environment.systemPackages = with pkgs; [
      brave
      google-chrome
    ];
  };
}
