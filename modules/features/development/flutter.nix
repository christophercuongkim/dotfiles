# Flutter SDK
{ ... }:
{
  flake.modules.nixos.flutter = { pkgs, ... }: {
    environment.systemPackages = with pkgs; [ flutter ];
  };
}
