# Provides home-manager modules that can be composed into NixOS configurations.
# Based on gaetanlepage's nix-config pattern
topLevel@{ inputs, ... }:
let
  username = topLevel.config.username;
in
{
  # Base home-manager module with core settings
  flake.modules.homeManager.core = {
    home.username = username;
    home.homeDirectory = "/home/${username}";
    home.stateVersion = "25.11";
    programs.home-manager.enable = true;
    systemd.user.startServices = "sd-switch";

    # Session variables for Wayland
    home.sessionVariables = {
      NIXOS_OZONE_WL = "1";
      HYPRSHOT_DIR = "/home/${username}/Pictures";
      GDK_BACKEND = "wayland";
    };
  };

  # NixOS module that wires up home-manager
  flake.modules.nixos.home-manager =
    { config, ... }:
    {
      imports = [ inputs.home-manager.nixosModules.home-manager ];

      home-manager = {
        useGlobalPkgs = true;
        extraSpecialArgs = {
          inherit inputs;
          dotfilesPath = inputs.self;
        };
        users.${username}.imports = [
          topLevel.config.flake.modules.homeManager.core
          topLevel.config.flake.modules.homeManager.symlinks
          topLevel.config.flake.modules.homeManager.git
          topLevel.config.flake.modules.homeManager.gtk
          topLevel.config.flake.modules.homeManager.waybar
          topLevel.config.flake.modules.homeManager.terminals
          topLevel.config.flake.modules.homeManager.networkmanager
        ];
      };
    };
}
