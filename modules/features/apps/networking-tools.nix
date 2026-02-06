# Network analysis tools
# TEMPORARILY DISABLED - home-manager contributions
{ ... }:
{
  flake.modules.nixos.networking-tools = { pkgs, ... }: {
    environment.systemPackages = with pkgs; [
      nmap
      wireshark
    ];
  };
}
