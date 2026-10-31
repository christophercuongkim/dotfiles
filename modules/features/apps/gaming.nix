# Gaming (Steam)
# TEMPORARILY DISABLED - home-manager contributions
{ ... }:
{
  flake.modules.nixos.gaming = { pkgs, ... }: {
    environment.systemPackages = with pkgs; [ 
      steam
      discord
      faugus-launcher
      mangohud
    ];
    programs.gamemode.enable = true;
  };
}
