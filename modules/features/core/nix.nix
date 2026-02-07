# Nix settings and flakes configuration
{ ... }:
{
  flake.modules.nixos.nix = {
    nix.settings.experimental-features = [ "nix-command" "flakes" ];
    nixpkgs.config.allowUnfree = true;
    system.autoUpgrade = {
      enable = true;
      allowReboot = false;
      dates = "04:00";
    };
  };
}
