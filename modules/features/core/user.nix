# User account configuration
{ config, ... }:
{
  flake.modules.nixos.user = { pkgs, ... }: {
    users.users.${config.username} = {
      isNormalUser = true;
      description = "Chris Kim";
      extraGroups = [
        "networkmanager"
        "wheel"
        "input"
        "vboxusers"
        "docker"
        "lpadmin"
        "video"
      ];
    };
  };
}
