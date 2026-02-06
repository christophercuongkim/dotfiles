# NetworkManager configuration
{ ... }:
{
  flake.modules.nixos.networkmanager = { pkgs, ... }: {
    networking.networkmanager = {
      enable = true;
      wifi.powersave = false;
      plugins = with pkgs; [
        networkmanager-openvpn
        networkmanager-openconnect
        networkmanager-strongswan
      ];
    };

    systemd.services.NetworkManager.serviceConfig.LimitNOFILE = 65535;
    systemd.services.wpa_supplicant.serviceConfig.LimitNOFILE = 65535;
  };
}
