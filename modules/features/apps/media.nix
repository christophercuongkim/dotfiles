# Media applications (Spotify, OBS, etc.)
# TEMPORARILY DISABLED - home-manager contributions
{ ... }:
{
  flake.modules.nixos.media = { pkgs, ... }: {
    environment.systemPackages = with pkgs; [
      ffmpeg
      ani-cli
      gimp
      obs-studio
      spotify
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
      (calibre.override {
        unrarSupport = true;
      })
      unrar
    ];

    services.udisks2 = {
      enable = true;
      mountOnMedia = true;
    };

    # Calibre udev rules for USB e-reader detection
    services.udev.packages = with pkgs; [
      (calibre.override { unrarSupport = true; })
    ];

    # ROCm OpenCL needed for DaVinci Resolve on AMD
    hardware.graphics.extraPackages = with pkgs; [
      rocmPackages.clr.icd
    ];
  };
}
