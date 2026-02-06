# Provides development shells as flake outputs.
{ ... }:
{
  perSystem = { pkgs, ... }: {
    devShells = {
      default = pkgs.mkShell {
        name = "dotfiles";
        packages = with pkgs; [
          nil
          nixfmt-rfc-style
        ];
      };
    };
  };
}
