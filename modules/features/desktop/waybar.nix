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

  # Enable waybar via home-manager (config managed via dotfiles symlink)
  flake.modules.homeManager.waybar = {
    programs.waybar.enable = true;
  };
}
