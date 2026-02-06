# Python programming language
{ ... }:
{
  flake.modules.nixos.python = { pkgs, ... }: {
    environment.systemPackages = with pkgs; [
      python3
      pipenv
      pyenv
      uv
    ];
  };
}
