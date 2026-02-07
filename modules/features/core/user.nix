# Primary user account configuration
#
# Groups:
#   - wheel: sudo access
#   - networkmanager: manage network connections
#   - input: access input devices (needed for some Wayland features)
#   - vboxusers: VirtualBox access
#   - docker: run Docker without sudo
#   - lpadmin: manage printers
#   - video: access GPU/display devices
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
