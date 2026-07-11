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

      # SSH public keys permitted to log in as this user (pubkey-only sshd).
      openssh.authorizedKeys.keys = [
        # iPhone (iphone171)
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPB4idmLg4qp6JFjl8Tdb4JQNO3KcP0p7Va0Pwgp/Xsf iphone"
      ];

      extraGroups = [
        "networkmanager"
        "wheel"
        "input"
        "vboxusers"
        "docker"
        "lpadmin"
        "video"
        "plugdev"
      ];
    };
  };
}
