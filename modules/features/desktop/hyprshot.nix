# Hyprshot screenshot tool
{ ... }:
{
  flake.modules.nixos.hyprshot = { pkgs, ... }: {
    environment.systemPackages = with pkgs; [
      hyprshot
      grim
      jq
      slurp
      wl-clipboard
    ];
  };
}
