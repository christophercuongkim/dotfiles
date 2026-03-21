# Media applications (Spotify, OBS, etc.)
# TEMPORARILY DISABLED - home-manager contributions
{ ... }:
{
  flake.modules.nixos.media = { pkgs, ... }: {
    environment.systemPackages = with pkgs; [
      ani-cli
      gimp
      obs-studio
      spotify
      poppler-utils
    ];
  };
}
