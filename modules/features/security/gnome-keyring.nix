# GNOME Keyring
{ ... }:
{
  flake.modules.nixos.gnome-keyring = {
    services.gnome.gnome-keyring.enable = true;

    # Unlocks the login keyring with the login password.
    security.pam.services.login.enableGnomeKeyring = true;

    # Keeps the keyring's own passphrase in step when the account password is
    # changed with `passwd`. Without this, `passwd` rewrites /etc/shadow while
    # the keyring stays encrypted with the old password, so login succeeds and
    # every keyring prompt afterwards rejects the new password -- including the
    # one NetworkManager uses for saved wifi secrets.
    #
    # Only affects future password changes; it cannot re-key a keyring that is
    # already out of sync.
    security.pam.services.passwd.enableGnomeKeyring = true;
  };
}
