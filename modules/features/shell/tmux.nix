# Tmux terminal multiplexer
# Config and plugins managed via dotfiles symlink in symlinks.nix
{ ... }:
{
  flake.modules.nixos.tmux = { pkgs, ... }: {
    environment.systemPackages = with pkgs; [ tmux ];
  };
}
