{ config, pkgs, inputs, ... }:

let
  username = "chriskim";
  dotfiles_path = "${inputs.self}";
in
{
  home.username = "${username}";
  home.homeDirectory = "/home/${username}";
  
  home.stateVersion = "25.11";

  nixpkgs.config = {
    allowUnfree = true;
  };

  programs.git = {
    enable = true;
    settings = {
      user.name = "Chris Kim";
      user.email = "christopher.cuong.kim@gmail.com";
      core.editor = "nvim";
    };
  };

  programs.tmux = {
    enable = true;
    shell = "${pkgs.zsh}/bin/zsh";
    terminal = "tmux-256color";
  };

  home.packages = with pkgs; [
    adwaita-icon-theme
    brave
    claude-code
    fastfetch
    firefox
    flutter
    fzf
    gh
    ghostty
    gimp
    git
    github-desktop
    gnome-themes-extra
    go
    google-chrome
    gsettings-desktop-schemas
    gsettings-desktop-schemas
    gtk3
    gtk4
    lua
    luarocks
    neovim
    nmap
    nodejs
    obs-studio
    oh-my-posh
    p7zip
    pipenv
    pyenv
    python3
    rink
    ripgrep
    slack
    spotify
    steam
    stow
    tmux
    tree
    unrar
    unzip
    wget
    wireshark
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

  # anyrun

    #programs.anyrun = {
    #  enable = true;
    #
    #  config = {
    #    width = { fraction = 0.6; };
    #    height = { fraction = 0.2; };
    #    x = { fraction = 0.5; };
    #    y = { fraction = 0.2; };
    #    plugins = [
    #      "${inputs.anyrun.packages.${pkgs.system}.anyrun-with-all-plugins}/lib/libapplications.so"
    #      "${inputs.anyrun.packages.${pkgs.system}.anyrun-with-all-plugins}/lib/libsymbols.so"
    #      "${inputs.anyrun.packages.${pkgs.system}.anyrun-with-all-plugins}/lib/librink.so"
    #      "${inputs.anyrun.packages.${pkgs.system}.anyrun-with-all-plugins}/lib/libshell.so"
    #      "${inputs.anyrun.packages.${pkgs.system}.anyrun-with-all-plugins}/lib/libtranslate.so"
    #      "${inputs.anyrun.packages.${pkgs.system}.anyrun-with-all-plugins}/lib/libdictionary.so"
    #      "${inputs.anyrun.packages.${pkgs.system}.anyrun-with-all-plugins}/lib/libwebsearch.so"
    #    ];
    #  };
    #};

  home.file.".config/anyrun".source = "${dotfiles_path}/.config/anyrun";
  home.file.".config/anyrun".recursive = true;

  # waybar
  home.file.".config/waybar".source = "${dotfiles_path}/.config/waybar";
  home.file.".config/waybar".recursive = true;

  # rofi config
  home.file.".config/rofi/config.rasi".source = "${dotfiles_path}/.config/rofi/config.rasi";

  # Enable GTK theme if needed
  gtk.enable = true;

  programs.home-manager.enable = true;

  # hyprland
  home.file.".config/hypr".source = "${dotfiles_path}/.config/hypr";
  home.file.".config/hypr".recursive = true;

  #waybar
  programs.waybar.enable = true;

  programs.kitty.enable = true; # required for the default Hyprland config

  home.sessionVariables = {
    # Optional, hint Electron apps to use Wayland:
    NIXOS_OZONE_WL = "1";
    HYPRSHOT_DIR = "/home/chriskim/Pictures";
    GDK_BACKEND = "wayland";
  };


}


