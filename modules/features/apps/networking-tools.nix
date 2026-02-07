# Network analysis and security tools
{ ... }:
{
  flake.modules.nixos.networking-tools = { pkgs, ... }: {
    environment.systemPackages = with pkgs; [
      nmap
      wireshark
    ];
  };
}
