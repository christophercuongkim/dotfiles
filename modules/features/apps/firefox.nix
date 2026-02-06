# Firefox browser
{ ... }:
{
  flake.modules.nixos.firefox = { pkgs, ... }: {
    programs.firefox = {
      enable = true;
      policies.ProtocolHandlers.Exclude = [ "myapp" ];
    };
    environment.systemPackages = with pkgs; [ firefox ];
  };
}
