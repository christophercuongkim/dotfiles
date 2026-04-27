# Rust programming language
{ ... }:
{
  flake.modules.nixos.rust = { pkgs, ... }: {
    environment.systemPackages = with pkgs; [ 
      rustup
      cargo
      rustc
      rust-analyzer
      clippy
      rustfmt
    ];
  };
}
