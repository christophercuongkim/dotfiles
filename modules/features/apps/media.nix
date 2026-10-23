# Media applications (Spotify, OBS, etc.)
# TEMPORARILY DISABLED - home-manager contributions
{ ... }:
{
  flake.modules.nixos.media = { pkgs, ... }: {
    environment.systemPackages = with pkgs; [
      ffmpeg
      # ani-cli runs from ~/repos/ani-cli; nix provides only its runtime deps
      mpv
      yt-dlp
      curl-impersonate
      gimp
      obs-studio
      spotify
      vlc
      poppler-utils
      # DR bundles Qt5 without Wayland plugin — wrap to force XWayland
      (symlinkJoin {
        name = "davinci-resolve";
        paths = [ davinci-resolve ];
        buildInputs = [ makeWrapper ];
        postBuild = ''
          wrapProgram $out/bin/davinci-resolve \
            --set QT_QPA_PLATFORM xcb
        '';
      })
      kdePackages.kdenlive
      calibre
      unrar
    ];

    services.udisks2 = {
      enable = true;
      mountOnMedia = true;
    };

    # Calibre udev rules for USB e-reader detection
    services.udev.packages = with pkgs; [
      calibre
    ];

    # ROCm OpenCL needed for DaVinci Resolve on AMD
    hardware.graphics.extraPackages = with pkgs; [
      rocmPackages.clr.icd
    ];
  };
}
