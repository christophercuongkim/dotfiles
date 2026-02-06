# Polkit rules
{ ... }:
{
  flake.modules.nixos.polkit = { pkgs, ... }: {
    security.polkit.enable = true;
    security.polkit.extraConfig = ''
      polkit.addRule(function(action, subject) {
        if (action.id == "net.reactivated.fprint.device.enroll" &&
            subject.isInGroup("wheel")) {
          return polkit.Result.YES;
        }
      });
    '';

    environment.systemPackages = with pkgs; [
      hyprpolkitagent
    ];
  };
}
