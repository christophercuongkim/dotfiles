# Provides custom packages as flake outputs.
{ inputs, ... }:
{
  perSystem = { pkgs, system, ... }: {
    packages = {
      anyrun = inputs.anyrun.packages.${system}.anyrun-with-all-plugins;
      waybar = inputs.waybar.packages.${system}.waybar;
    };
  };
}
