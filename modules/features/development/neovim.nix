# Neovim text editor
{ ... }:
{
  flake.modules.nixos.neovim = { pkgs, ... }: {
    environment.systemPackages = with pkgs; [
      # Plain `pkgs.neovim` wraps nvim with `vim.g.loaded_python3_provider=0`,
      # which kills python remote plugins outright -- no config-side setting can
      # re-enable it. molten-nvim is one, so the provider is switched on here
      # and given the packages it needs. Non-Nix machines get the same thing
      # from a ~/.virtualenvs/neovim venv (see lua/custom/platform.lua).
      (neovim.override {
        withPython3 = true;
        extraPython3Packages = ps: with ps; [
          pynvim
          jupyter-client
          cairosvg # svg plot output
          pnglatex # latex/math output
          pillow
          nbformat
          pyperclip
        ];
      })
      # Treesitter CLI for parser compilation
      tree-sitter
      # .ipynb <-> markdown conversion for jupytext.nvim
      python3Packages.jupytext
      # image.nvim renders plots by shelling out to ImageMagick
      imagemagick
    ];
  };
}
