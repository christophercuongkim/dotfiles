# GNOME Keyring
{ ... }:
{
  flake.modules.nixos.gnome-keyring = {
    services.gnome.gnome-keyring.enable = true;
    security.pam.services.login.enableGnomeKeyring = true;
  };
}
