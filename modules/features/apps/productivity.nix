# Productivity applications
# TEMPORARILY DISABLED - home-manager contributions
{ ... }:
{
  flake.modules.nixos.productivity = { pkgs, ... }: {
    environment.systemPackages = with pkgs; [
      obsidian
      slack
      claude-code
      zotero
    ];
  };
}
