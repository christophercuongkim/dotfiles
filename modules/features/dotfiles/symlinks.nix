# Dotfiles symlinks via home-manager
{ ... }:
{
  # dotfilesPath is passed via extraSpecialArgs in home-manager.nix
  flake.modules.homeManager.symlinks = { dotfilesPath, pkgs, ... }: {
    home.file = {
      # Shell
      ".zshrc".source = "${dotfilesPath}/.zshrc";

      # Terminals
      ".config/alacritty".source = "${dotfilesPath}/.config/alacritty";
      ".config/ghostty/config".source = "${dotfilesPath}/.config/ghostty/config";

      # Editor
      ".config/nvim".source = "${dotfilesPath}/.config/nvim";

      # Shell prompt
      ".config/oh-my-posh".source = "${dotfilesPath}/.config/oh-my-posh";

      # Tmux (whole directory including plugins)
      ".config/tmux".source = "${dotfilesPath}/.config/tmux";

      # SSH
      ".ssh/config".source = "${dotfilesPath}/.ssh/config";
      ".ssh/rc".source = "${dotfilesPath}/.ssh/rc";

      # 1Password SSH agent
      ".config/1Password/ssh/agent.toml".source = "${dotfilesPath}/.config/1Password/ssh/agent.toml";

      # Nix
      ".config/nix".source = "${dotfilesPath}/.config/nix";

      # Stow
      ".stow-global-ignore".source = "${dotfilesPath}/.stow-global-ignore";

      # Desktop environment
      ".config/anyrun".source = "${dotfilesPath}/.config/anyrun";
      ".config/waybar".source = "${dotfilesPath}/.config/waybar";
      ".config/rofi".source = "${dotfilesPath}/.config/rofi";
      # mako re-reads its config only when told to. home-manager's own mako
      # module does exactly this (modules/services/mako.nix, onChange), but only
      # when it writes the config itself -- which it does not here, because
      # `settings` is left empty so this symlink wins.
      ".config/mako" = {
        source = "${dotfilesPath}/.config/mako";
        onChange = "${pkgs.mako}/bin/makoctl reload || true";
      };
      ".config/hypr".source = "${dotfilesPath}/.config/hypr";
      ".config/hyprpaper/hyprpaper.conf".source = "${dotfilesPath}/.config/hypr/hyprpaper.conf";
    };
  };
}
