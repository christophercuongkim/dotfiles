# Hyprpaper wallpaper daemon
{ ... }:
{
  flake.modules.nixos.hyprpaper = { pkgs, ... }: {
    environment.systemPackages = with pkgs; [
      hyprpaper
    ];
  };
}
