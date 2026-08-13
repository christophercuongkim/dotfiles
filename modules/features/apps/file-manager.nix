# Dolphin file manager and KDE extras
{ ... }:
{
  flake.modules.nixos.file-manager = { pkgs, ... }: {
    environment.systemPackages = with pkgs; [
      kdePackages.dolphin
      kdePackages.kde-cli-tools
      kdePackages.kio-extras
      kdePackages.kio-fuse
      kdePackages.kservice
      kdePackages.qtsvg
      kdePackages.gwenview
    ];
  };
}
