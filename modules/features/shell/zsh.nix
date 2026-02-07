# Zsh shell configuration
#
# Sets zsh as the default shell for the primary user.
# Shell configuration (plugins, aliases, etc.) is managed via
# dotfiles symlink at ~/.zshrc for cross-platform compatibility.
#
# Uses zinit for plugin management - see .zshrc for details.
{ config, ... }:
{
  flake.modules.nixos.zsh = { pkgs, ... }: {
    programs.zsh.enable = true;
    users.users.${config.username}.shell = pkgs.zsh;
    environment.systemPackages = with pkgs; [ zsh ];
  };
}
