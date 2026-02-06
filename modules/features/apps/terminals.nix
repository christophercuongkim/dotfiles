# Terminal emulators
{ ... }:
{
  flake.modules.nixos.terminals = { pkgs, ... }: {
    environment.systemPackages = with pkgs; [
      kitty
      ghostty
    ];
  };

  # Kitty is required for default Hyprland config
  flake.modules.homeManager.terminals = {
    programs.kitty.enable = true;
  };
}
