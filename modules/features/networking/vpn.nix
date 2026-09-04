# VPN tools (ProtonVPN, OpenVPN)
{ ... }:
{
  flake.modules.nixos.vpn = { pkgs, ... }: {
    environment.systemPackages = with pkgs; [
      proton-vpn
      openvpn
    ];
  };
}
