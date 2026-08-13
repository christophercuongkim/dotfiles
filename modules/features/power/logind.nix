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

    systemd.sleep.settings.Sleep = {
      # How long to stay suspended before hibernating.
      HibernateDelaySec = "60min";

      # Write the image then power off (S5). The kernel default "platform"
      # (ACPI S4) fails to enter on this Framework/AMD board: the screen
      # blanks but the machine stays powered and no image is written
      # ("PM: Image not found" on next boot). "shutdown" mode is reliable.
      HibernateMode = "shutdown";
    };
  };
}
