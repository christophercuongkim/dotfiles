# Media applications (Spotify, OBS, etc.)
# TEMPORARILY DISABLED - home-manager contributions
{ ... }:
{
  flake.modules.nixos.music = { pkgs, ... }: {
    environment.systemPackages = with pkgs; [
      ardour
      winePackages.stagingFull
      winetricks
      yabridge
      yabridgectl
    ];
  };
}
