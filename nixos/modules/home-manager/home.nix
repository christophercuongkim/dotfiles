{ config, pkgs, inputs, ... }:

let
  username = "chriskim";
  dotfiles_path = "${inputs.self}";
in
{
  home.username = "${username}";
  home.homeDirectory = "/home/${username}";
  
  home.stateVersion = "25.11";

  programs.zsh.enable = true;
  programs.git = {
    enable = true;
    userName = "Chris Kim";
    userEmail = "christopher.cuong.kim@gmail.com";
  };

  programs.tmux = {
    enable = true;
    shell = "${pkgs.zsh}/bin/zsh";
    terminal = "tmux-256color";
  };

  home.packages = with pkgs; [
    firefox
    fzf
    gh
    ghostty
    git
    github-desktop
    go
    lua
    luarocks
    neovim
    nodejs
    oh-my-posh
    pipenv
    pyenv
    python3
    ripgrep
    stow
    tmux
    tree
    unzip
    virtualbox
    wget
    wl-clipboard
    zig
    zoxide
    zsh
  ];

  # Link dotfiles - use relative paths from your dotfiles repo
  home.file.".zshrc".source = "${dotfiles_path}/.zshrc";
  
  # Alacritty config
  home.file.".config/alacritty/alacritty.toml".source = "${dotfiles_path}/.config/alacritty/alacritty.toml";
  
  # Neovim config (entire directory)
  home.file.".config/nvim".source = "${dotfiles_path}/.config/nvim";
  home.file.".config/nvim".recursive = true;
  
  # Oh-my-posh config
  home.file.".config/oh-my-posh".source = "${dotfiles_path}/.config/oh-my-posh";
  home.file.".config/oh-my-posh".recursive = true;
  
  # Tmux config
  home.file.".config/tmux".source = "${dotfiles_path}/.config/tmux";
  home.file.".config/tmux".recursive = true;
  home.file.".config/tmux/plugins/catppuccin-tmux".source = pkgs.fetchFromGitHub {
    owner = "dreamsofcode-io";
    repo = "catppuccin-tmux";
    rev = "main";
    sha256 = "sha256-FJHM6LJkiAwxaLd5pnAoF3a7AE1ZqHWoCpUJE0ncCA8=";
  };
  home.file.".config/tmux/plugins/tmux-sensible".source = pkgs.fetchFromGitHub {
    owner = "tmux-plugins";
    repo = "tmux-sensible";
    rev = "master";
    sha256 = "sha256-hW8mfwB8F9ZkTQ72WQp/1fy8KL1IIYMZBtZYIwZdMQc=";
  };
  home.file.".config/tmux/plugins/tmux-yank".source = pkgs.fetchFromGitHub {
    owner = "tmux-plugins";
    repo = "tmux-yank";
    rev = "master";
    sha256 = "sha256-hW8mfwB8F9ZkTQ72WQp/1fy8KL1IIYMZBtZYIwZdMQc=";
  };
  home.file.".config/tmux/plugins/tpm".source = pkgs.fetchFromGitHub {
    owner = "tmux-plugins";
    repo = "tpm";
    rev = "master";
    sha256 = "sha256-hW8mfwB8F9ZkTQ72WQp/1fy8KL1IIYMZBtZYIwZdMQc=";
  };
  home.file.".config/tmux/plugins/vim-tmux-navigator".source = pkgs.fetchFromGitHub {
    owner = "christoomey";
    repo = "vim-tmux-navigator";
    rev = "master";
    sha256 = "sha256-czhzY1bauNd472osfUZSzsOEoGv9QhQBriF3ULkKNpY=";
  };

  # SSH config
  home.file.".ssh/config".source = "${dotfiles_path}/.ssh/config";
  home.file.".ssh/rc".source = "${dotfiles_path}/.ssh/rc";
  
  # 1Password SSH agent config
  home.file.".config/1Password/ssh/agent.toml".source = "${dotfiles_path}/.config/1Password/ssh/agent.toml";
  
  # Nix config
  home.file.".config/nix/nix.conf".source = "${dotfiles_path}/.config/nix/nix.conf";
  
  # Stow ignore file
  home.file.".stow-global-ignore".source = "${dotfiles_path}/.stow-global-ignore";

  # ghostty config
  home.file.".config/ghostty/config".source = "${dotfiles_path}/.config/ghostty/config";

  # rofi config
  home.file.".config/rofi/config.rasi".source = "${dotfiles_path}/.config/rofi/config.rasi";


  # ghostty desktop app
  home.file.".local/share/applications/ghostty.desktop" = {
    text = ''
      [Desktop Entry]
      Name=Ghostty
      Comment=A terminal-based application
      Exec=ghostty
      Icon=utilities-terminal  # Change this if you have a custom icon
      Terminal=true
      Type=Application
      Categories=Utility;TerminalEmulator;
    '';
  };
  



  # Enable GTK theme if needed
  gtk.enable = true;

  programs.home-manager.enable = true;

  

  # hyprland
  home.file.".config/hypr/hyprland.conf".source = "${dotfiles_path}/.config/hypr/hyprland.conf";
  home.file.".config/hypr/hyprlock.conf".source = "${dotfiles_path}/.config/hypr/hyprlock.conf";

  programs.kitty.enable = true; # required for the default Hyprland config

  # Optional, hint Electron apps to use Wayland:
  home.sessionVariables.NIXOS_OZONE_WL = "1";

}


