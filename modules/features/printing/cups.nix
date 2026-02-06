# CUPS printing system
{ ... }:
{
  flake.modules.nixos.cups = { pkgs, ... }: {
    services.printing = {
      enable = true;
      drivers = [ pkgs.gutenprint ];
    };
  };
}
