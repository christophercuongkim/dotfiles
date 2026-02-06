# Hyprland compositor configuration
{ ... }:
{
  flake.modules.nixos.hyprland = { pkgs, ... }: {
    services.xserver.enable = false;

    programs.hyprland = {
      enable = true;
      withUWSM = true;
    };

    environment.systemPackages = with pkgs; [
      hyprland
    ];
  };

  # Config is managed via dotfiles symlink (.config/hypr)
}
