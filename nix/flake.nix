{
  description = "Package set for my system";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }: let
    pkgs = nixpkgs.legacyPackages.x86_64-linux;
  in {
    packages.x86_64-linux.default = pkgs.buildEnv {
      name = "my-packages";
      paths = [
        pkgs.git
        pkgs.neovim
        pkgs.fd
        pkgs.bat
        pkgs.go
        pkgs.python3Full
        pkgs.zsh
        pkgs.oh-my-posh
        pkgs.ripgrep
        pkgs.fzf
        pkgs.zoxide
        pkgs.pyenv
        pkgs.pipenv
        pkgs.ghostty
      ];
    };
  };
}
