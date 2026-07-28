# Logind lid switch behavior
{ ... }:
{
  flake.modules.nixos.logind = {
    services.logind = {
      settings = {
        Login = {
          # Suspend to RAM immediately, hibernate to disk after the delay
          # below (uses boot.resumeDevice / swap for resume).
          HandleLidSwitch = "suspend-then-hibernate";
          HandleLidSwitchDocked = "ignore";
          HandleLidSwitchExternalPower = "suspend-then-hibernate";
        };
      };
    };

    # How long to stay suspended before hibernating.
    systemd.sleep.settings.Sleep = {
      HibernateDelaySec = "60min";
    };
  };
}
