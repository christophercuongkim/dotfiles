# nix-ld: run unpatched dynamically-linked binaries (Android SDK, Flutter
# prebuilt tools like adb/aapt2/emulator) that expect a generic FHS loader.
{ ... }:
{
  flake.modules.nixos.nix-ld = { pkgs, ... }: {
    programs.nix-ld = {
      enable = true;
      # Libraries exposed via NIX_LD_LIBRARY_PATH to those binaries.
      libraries = with pkgs; [
        zlib
        zstd
        stdenv.cc.cc.lib   # libstdc++
        ncurses5
        libgcc.lib
      ];
    };
  };
}
