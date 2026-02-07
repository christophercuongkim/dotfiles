# Greetd login manager
{ config, ... }:
{
  flake.modules.nixos.greetd = {
    services.greetd = {
      enable = true;
      settings = rec {
        initial_session = {
          command = "uwsm start hyprland-uwsm.desktop";
          user = config.username;
        };
        default_session = initial_session;
      };
    };
  };
}
