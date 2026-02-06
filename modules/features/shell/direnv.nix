# direnv with nix-direnv for automatic devshell activation
{ ... }:
{
  flake.modules.nixos.direnv = { pkgs, ... }: {
    programs.direnv = {
      enable = true;
      nix-direnv.enable = true;  # Caches devshells for faster activation
    };
  };
}
