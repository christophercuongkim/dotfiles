# Greetd login manager
{ config, ... }:
{
  flake.modules.nixos.greetd = {
    services.greetd = {
      enable = true;
      settings = rec {
        initial_sesstion = {
          command = "hyprland > /dev/null 2>&1";
          user = config.username;
        };
        default_session = initial_sesstion;
      };
    };
  };
}
