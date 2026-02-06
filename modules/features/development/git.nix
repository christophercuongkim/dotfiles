# Git version control
{ ... }:
{
  flake.modules.nixos.git = { pkgs, ... }: {
    environment.systemPackages = with pkgs; [
      git
      gh
      github-desktop
    ];
  };

  flake.modules.homeManager.git = {
    programs.git = {
      enable = true;
      settings = {
        user.name = "Chris Kim";
        user.email = "christopher.cuong.kim@gmail.com";
        core.editor = "nvim";
      };
    };
  };
}
