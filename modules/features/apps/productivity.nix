# Productivity applications
# TEMPORARILY DISABLED - home-manager contributions
{ ... }:
{
  flake.modules.nixos.productivity = { pkgs, ... }: {
    environment.systemPackages = with pkgs; [
      obsidian
      slack
      claude-code
      sox # claude-code voice mode mic capture
      code-cursor
      cursor-cli
      codex
      opencode
    ];
  };
}
