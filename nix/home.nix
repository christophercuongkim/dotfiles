{ config, pkgs, ... }:

let
  dotfiles_path = "/home/chriskim/dotfiles";
in
{
  home.username = "chriskim";
  home.homeDirectory = "/home/chriskim";

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
  home.file.".tmux.conf".source = "${dotfiles_path}/.config/tmux/tmux.conf";
  home.file.".tmux".source = "${dotfiles_path}/.tmux";
  home.file.".tmux".recursive = true;
  
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

  



  # Enable GTK theme if needed
  gtk.enable = true;

  programs.home-manager.enable = true;
}


