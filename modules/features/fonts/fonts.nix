# Font packages and fontconfig
{ ... }:
{
  flake.modules.nixos.fonts = { pkgs, ... }: {
    fonts = {
      enableDefaultPackages = true;

      packages = with pkgs; [
        nerd-fonts.jetbrains-mono
        noto-fonts
        noto-fonts-cjk-sans
        noto-fonts-color-emoji
      ];

      fontconfig = {
        enable = true;
        defaultFonts = {
          serif = [ "Noto Serif" "JetBrainsMono" ];
          sansSerif = [ "Noto Sans" "JetBrainsMono" ];
          monospace = [ "JetBrainsMono" ];
          emoji = [ "Noto Color Emoji" ];
        };
      };
    };

    environment.systemPackages = with pkgs; [
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-color-emoji
      nerd-fonts.jetbrains-mono
    ];
  };
}
