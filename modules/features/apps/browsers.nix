# Other browsers (Brave, Chrome)
# TEMPORARILY DISABLED - home-manager contributions
{ ... }:
{
  flake.modules.nixos.browsers = { pkgs, ... }: {
    environment.systemPackages = with pkgs; [
      brave
      google-chrome
    ];
  };
}
