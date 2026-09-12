# Hyprlock lock screen
{ ... }:
{
  flake.modules.nixos.hyprlock = { pkgs, ... }: {
    # Fingerprint is handled by hyprlock itself over DBus (auth:fingerprint in
    # hyprlock.conf), so keep pam_fprintd out of the stack. With both enabled
    # they race to Claim the Goodix reader -- PAM loses ("Device was already
    # claimed"), the conversation fails, and the typed password does not reach
    # pam_unix until fprintd's timeouts unwind.
    security.pam.services.hyprlock.fprintAuth = false;

    environment.systemPackages = with pkgs; [
      hyprlock
    ];
  };
}
