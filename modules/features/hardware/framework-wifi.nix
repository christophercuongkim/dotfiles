# Framework laptop WiFi power management (mt7925e driver)
{ ... }:
{
  flake.modules.nixos.framework-wifi = {
    boot.extraModprobeConfig = ''
      # wifi power management
      options mt7925e disable_aspm=1
      options mt7925e disable_pm=1
    '';
  };
}
