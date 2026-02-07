# Git version control with GitHub integration
#
# Packages:
#   - git: Core version control
#   - gh: GitHub CLI for PRs, issues, etc.
#   - github-desktop: GUI for git operations
#
# Home-manager configures user identity and default editor.
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
