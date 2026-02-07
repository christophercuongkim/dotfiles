# Firewall configuration
#
# Enables the NixOS firewall with sensible defaults.
# All incoming connections are blocked except explicitly allowed ports.
# Outgoing connections are unrestricted.
#
# To allow additional ports, add them to allowedTCPPorts or allowedUDPPorts.
{ ... }:
{
  flake.modules.nixos.firewall = {
    networking.firewall = {
      enable = true;
      allowedTCPPorts = [
        # Add ports as needed, e.g.:
        # 22    # SSH (if you want external access)
        # 80    # HTTP
        # 443   # HTTPS
      ];
      allowedUDPPorts = [
        # Add ports as needed
      ];
      # Allow all traffic from Tailscale network
      trustedInterfaces = [ "tailscale0" ];
    };
  };
}
