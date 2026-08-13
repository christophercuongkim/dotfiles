# AppleII host configuration (Framework AMD AI 300-series laptop)
{ config, inputs, ... }:
let
  inherit (config.flake.modules) nixos;
in
{
  config = {
    configurations.nixos.AppleII.module = {
      imports = [
        # Hardware
        inputs.nixos-hardware.nixosModules.framework-amd-ai-300-series
        nixos.AppleII-hardware

        # Core
        nixos.nix
        nixos.locale
        nixos.boot
        nixos.user

        # Home-manager integration
        nixos.home-manager

        # Desktop
        nixos.hyprland
        nixos.greetd
        nixos.waybar
        nixos.rofi
        nixos.hyprlock
        nixos.hypridle
        nixos.hyprpaper
        nixos.portals
        nixos.wayland
        nixos.hyprshot
        nixos.anyrun
        nixos.mako

        # Networking
        nixos.networkmanager
        nixos.tailscale
        nixos.resolved
        nixos.vpn
        nixos.firewall

        # Audio/Bluetooth
        nixos.pipewire
        nixos.blueman

        # Security
        nixos."1password"
        nixos.polkit
        nixos.pam
        nixos.gnome-keyring
        nixos.ssh

        # Fingerprint
        nixos.fprintd

        # Printing
        nixos.cups
        nixos.avahi

        # Virtualization
        nixos.docker
        nixos.virtualbox

        # Fonts
        nixos.fonts

        # Shell
        nixos.zsh
        nixos.cli-tools
        nixos.tmux
        nixos.direnv

        # Development
        nixos.git
        nixos.neovim
        nixos.lsp
        nixos.python
        nixos.mysql
        nixos.nodejs
        nixos.go
        nixos.lua
        nixos.zig
        nixos.odin
        nixos.flutter
        nixos.java
        nixos.rust
        nixos.ollama
        nixos.android-tools
        nixos.nix-ld

        # Apps
        nixos.firefox
        nixos.file-manager
        nixos.browsers
        nixos.terminals
        nixos.media
        nixos.music
        nixos.productivity
        nixos.gaming
        nixos.gtk
        nixos.networking-tools

        # Power
        nixos.logind
        nixos.power-profiles

        # Hardware (Framework-specific)
        nixos.framework-webcam
        nixos.framework-wifi
        nixos.framework-udev
        nixos.firmware
      ];

      networking.hostName = "AppleII";
      system.stateVersion = "25.05";
    };
  };
}
