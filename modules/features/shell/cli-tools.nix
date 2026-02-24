# CLI tools (fzf, ripgrep, zoxide, etc.)
{ ... }:
{
  flake.modules.nixos.cli-tools = { pkgs, ... }: {
    environment.systemPackages = with pkgs; [
      brightnessctl
      fastfetch
      fd            # Fast file finder (telescope)
      fzf
      libnotify
      newt
      oh-my-posh
      p7zip
      pdftk
      qpdf
      rink
      ripgrep
      stow
      tree
      unrar
      unzip
      util-linux
      wget
      zoxide
    ];
  };
}
