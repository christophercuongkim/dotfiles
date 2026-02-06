# Tmux terminal multiplexer
# TEMPORARILY DISABLED - home-manager contributions
{ ... }:
{
  # Just install tmux via NixOS for now
  flake.modules.nixos.tmux = { pkgs, ... }: {
    environment.systemPackages = with pkgs; [ tmux ];
  };
}
