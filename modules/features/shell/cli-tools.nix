# CLI tools (fzf, ripgrep, zoxide, etc.)
{ ... }:
{
  flake.modules.nixos.cli-tools = { pkgs, ... }: {
    environment.systemPackages = with pkgs; [
      brightnessctl
      libnotify
      newt
      stow
      util-linux
      fastfetch
      fzf
      p7zip
      ripgrep
      tree
      unrar
      unzip
      wget
      zoxide
      oh-my-posh
    ];
  };
}
