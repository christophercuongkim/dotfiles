# Hyprland Wayland compositor
#
# A dynamic tiling compositor with animations and modern features.
# Uses UWSM (Universal Wayland Session Manager) for proper session management.
#
# Configuration is managed via dotfiles symlink at ~/.config/hypr/
# See .config/hypr/hyprland.conf for keybinds, monitors, and settings.
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
}
