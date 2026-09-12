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
  flake.modules.homeManager.waybar = { pkgs, dotfilesPath, ... }: {
    # See session-services.nix for why this is needed: the unit never mentions
    # the config, so without a trigger a rebuild leaves the running bar on the
    # config it read at login.
    systemd.user.services.waybar.Unit.X-Restart-Triggers = [
      (builtins.hashFile "sha256" "${dotfilesPath}/.config/waybar/config.jsonc")
      (builtins.hashFile "sha256" "${dotfilesPath}/.config/waybar/style.css")
    ];

    programs.waybar = {
      enable = true;
      package = pkgs.waybar_git;

      # Without this home-manager installs the package but no unit, which left
      # waybar being started by a stale hand-enabled symlink in
      # ~/.config/systemd/user pinning a year-old store path -- so the running
      # bar was not the one this flake builds.
      systemd.enable = true;
    };
  };
}
