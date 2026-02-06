# 1Password password manager
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
