# Mako notification daemon (displays notify-send / libnotify notifications).
{ ... }:
{
  flake.modules.nixos.mako = { pkgs, ... }: {
    environment.systemPackages = with pkgs; [
      mako
    ];
  };
}
