# Logind lid switch behavior
{ ... }:
{
  flake.modules.nixos.logind = {
    services.logind = {
      settings = {
        Login = {
          HandleLidSwitch = "suspend";
          HandleLidSwitchDocked = "ignore";
          HandleLidSwitchExternalPower = "suspend";
        };
      };
    };
  };
}
