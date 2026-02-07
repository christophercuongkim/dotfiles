# 1Password password manager
#
# Provides both CLI and GUI for password management.
# SSH agent integration configured in .zshrc for cross-platform support.
#
# polkitPolicyOwners allows the user to unlock 1Password without
# entering the system password repeatedly.
{ config, ... }:
{
  flake.modules.nixos."1password" = {
    programs._1password.enable = true;
    programs._1password-gui = {
      enable = true;
      polkitPolicyOwners = [ config.username ];
    };
  };
}
