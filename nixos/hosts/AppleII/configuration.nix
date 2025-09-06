# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, inputs, ... }:

let
  username = "chriskim";
  dotfiles_path = "/home/${username}/dotfiles";
  hostname = "AppleII";
in

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      inputs.home-manager.nixosModules.default
    ];

  # Enable flakes
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "${hostname}"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "America/New_York";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };
  services.fwupd.enable = true;

  # Tailscale
  services.tailscale.enable = true;
  # MagicDNS
  


  services.logind = {
    lidSwitch = "suspend";
    lidSwitchDocked = "ignore";  # optional: useful if external monitor/keyboard
    extraConfig = ''
      HandleLidSwitchExternalPower=suspend
    '';
  };

  services.power-profiles-daemon.enable = true;

  services.blueman.enable = true;

  # For bluetooth in general
  hardware.bluetooth.enable = true;
  services.dbus.packages = [ pkgs.blueman ];
  hardware.bluetooth.powerOnBoot = true;

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Enable zsh
  programs.zsh.enable = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;
  # Install firefox.
  programs.firefox = {
    enable = true;
    policies = {
      # Prevent Firefox from automatically exposing the protocol
      "ProtocolHandlers" = {
        "Exclude" = [ "myapp" ];  # Replace with your custom scheme (e.g. "slack", "zoommtg", etc.)
      };
    };
  };

  # install 1password
  programs._1password.enable = true;
  programs._1password-gui = {

    enable = true;
    polkitPolicyOwners = ["${username}"];

  };


  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.chriskim = {
    isNormalUser = true;
    description = "Chris Kim";
    shell = pkgs.zsh;
    extraGroups = [ "networkmanager" "wheel" "input" "vboxusers" "docker"];
    packages = with pkgs; [
    #  thunderbird
    ];
  };

  home-manager = {
    extraSpecialArgs = { 
      inherit inputs;
    };
    users = {
      "chriskim" = import ../../modules/home-manager/home.nix;
    };
  };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Enable autoupgrades
  system.autoUpgrade.enable = true;
  system.autoUpgrade.allowReboot = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.05"; # Did you read the comment?

  
  # system-wide packages
    environment.systemPackages = with pkgs; [
    brightnessctl
    git
    hypridle
    hyprland
    hyprlock
    hyprpaper
    hyprpolkitagent
    kdePackages.dolphin
    kdePackages.kde-cli-tools
    kdePackages.kio-extras #extra protocols support (sftp, fish and more)
    kdePackages.kio-fuse #to mount remote filesystems via FUSE
    kdePackages.kservice
    kdePackages.qtsvg
    libnotify
    neovim
    nerd-fonts.jetbrains-mono
    newt
    pavucontrol
    playerctl
    qimgv
    rofi
    stow
    util-linux
    waybar_git
    xdg-desktop-portal
    xdg-desktop-portal-gtk
    xdg-desktop-portal-wlr
    xdg-utils
    #hyprshot stuff
    hyprshot
    grim
    jq
    slurp
    wl-clipboard
  ];

  fonts = {
    enableDefaultPackages = false;
    packages = with pkgs; [
      nerd-fonts.jetbrains-mono
    ];
  
    fontconfig = {
      enable = true;
      defaultFonts = {
        serif = [  "JetBrainsMono" ];
        sansSerif = [ "JetBrainsMono" ];
        monospace = [ "JetBrainsMono" ];
      };
    };
  };

  # hyprland

  services.xserver.enable = false;  # Disable X11

  # Enable wayland and other compositor settings
  environment.variables = {
    XDG_SESSION_TYPE = "wayland";
    QT_QPA_PLATFORM = "wayland";
    MOZ_ENABLE_WAYLAND = "1"; # Enable Wayland support for Firefox
  };

  programs.hyprland = {
    enable = true;
    withUWSM = true;
  };

  security.pam.services.hyprlock = {};

  services.greetd = {
    enable = true;
    settings = rec {
      initial_sesstion = {
        command = "hyprland > /dev/null 2>&1";
        user = "${username}";
      };
      default_session = initial_sesstion;
    };
  };

  # Fingerprint
  # Start the driver at boot
  systemd.services.fprintd = {
    wantedBy = [ "multi-user.target" ];
    serviceConfig.Type = "simple";
  };
  
  # Install the driver
  services.fprintd = {
    enable = true;
    # If simply enabling fprintd is not enough, try enabling fprintd.tod...
    tod.enable = true;
    # ...and use one of the next four drivers
    #tod.driver = pkgs.libfprint-2-tod1-goodix; # Goodix driver module
    tod.driver = pkgs.libfprint-2-tod1-elan; # Elan(04f3:0c4b) driver
    #tod.driver = pkgs.libfprint-2-tod1-vfs0090; # (Marked as broken as of 2025/04/23!) driver for 2016 ThinkPads
    #tod.driver = pkgs.libfprint-2-tod1-goodix-550a; # Goodix 550a driver (from Lenovo)
  
    # however for focaltech 2808:a658, use fprintd with overidden package (without tod)
    # services.fprintd.package = pkgs.fprintd.override {
    #   libfprint = pkgs.libfprint-focaltech-2808-a658;
    # };
  };

  security.pam.services.login.fprintAuth = false;

  security.polkit.enable = true;
  security.polkit.extraConfig = ''
    polkit.addRule(function(action, subject) {
      if (action.id == "net.reactivated.fprint.device.enroll" &&
          subject.isInGroup("wheel")) {
        return polkit.Result.YES;
      }
    });
  '';

  virtualisation.virtualbox.host.enable = true;
  virtualisation.virtualbox.host.enableExtensionPack = true;
  boot.kernelParams = [ "kvm.enable_virt_at_load=0" ];
  boot.kernelModules = [ "vboxguest" "vboxsf" ];
  boot.extraModulePackages = with config.boot.kernelPackages; [
    virtualboxGuestAdditions
  ];


  virtualisation.docker = {
    enable = true;
  };




  services.dbus.enable = true;
  xdg.portal.enable = true;
  xdg.portal.wlr.enable = true;

  xdg.portal.extraPortals = [
    pkgs.xdg-desktop-portal-gtk
  ];
}
