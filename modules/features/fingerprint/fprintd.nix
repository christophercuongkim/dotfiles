# Fingerprint reader (Elan driver for Framework)
{ ... }:
{
  flake.modules.nixos.fprintd = { pkgs, ... }: {
    systemd.services.fprintd = {
      wantedBy = [ "multi-user.target" ];
      serviceConfig.Type = "simple";
    };

    services.fprintd = {
      enable = true;
      tod.enable = true;
      tod.driver = pkgs.libfprint-2-tod1-elan;
    };
  };
}
