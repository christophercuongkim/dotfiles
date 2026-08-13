# Odin programming language
#
# The nixpkgs `odin` package is self-contained: its wrapper puts clang, lld,
# and llvm-binutils on PATH and sets ODIN_ROOT to the bundled core/vendor
# libraries, so `odin build` / `odin run` links and runs without any extra
# toolchain. `ols` is the Odin language server (editor/LSP support).
{ ... }:
{
  flake.modules.nixos.odin = { pkgs, ... }: {
    environment.systemPackages = with pkgs; [
      odin
      ols
    ];
  };
}
