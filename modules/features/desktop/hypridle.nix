# Hypridle idle daemon
{ ... }:
{
  flake.modules.nixos.hypridle = { pkgs, ... }: {
    environment.systemPackages = with pkgs; [
      hypridle
    ];
  };
}
