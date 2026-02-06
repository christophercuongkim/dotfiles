# Anyrun application launcher
{ inputs, ... }:
{
  flake.modules.nixos.anyrun = { pkgs, ... }: {
    environment.systemPackages = [
      inputs.anyrun.packages.${pkgs.stdenv.hostPlatform.system}.anyrun-with-all-plugins
    ];
  };
}
