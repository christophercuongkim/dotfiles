# Zsh shell
{ config, ... }:
{
  flake.modules.nixos.zsh = { pkgs, ... }: {
    programs.zsh.enable = true;
    users.users.${config.username}.shell = pkgs.zsh;
    environment.systemPackages = with pkgs; [ zsh ];
  };
}
