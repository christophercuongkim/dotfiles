# Waybar status bar
{ inputs, ... }:
{
  flake.modules.nixos.waybar = { pkgs, ... }: {
    nixpkgs.overlays = [
      (_: _: { waybar_git = inputs.waybar.packages.${pkgs.stdenv.hostPlatform.system}.waybar; })
    ];

    environment.systemPackages = with pkgs; [
      waybar_git
    ];
  };

  # Config is managed via dotfiles symlink, no home-manager waybar program needed
}
