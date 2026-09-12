# Session services
#
# The daemons that make up a Hyprland session, as systemd user units rather
# than bare processes spawned from autostart.lua.
#
# Why: a bare process has no journal, no restart on failure, and keeps its old
# config after a rebuild until something restarts it by hand. That last one bit
# us during the Lua migration -- hypridle stayed on a pre-fix config and an
# idle test would have measured the wrong thing.
#
# Every service here is enabled with NO `settings`. Home-manager only writes a
# config file when settings is non-empty, so leaving it empty means these units
# read the configs symlinked from dotfiles (see dotfiles/symlinks.nix) and
# nothing collides. ExecStart is just the binary, so each daemon finds its
# config in the usual place.
#
# They bind to graphical-session.target, which UWSM brings up. Note that
# hyprland-session.target -- referenced in autostart.lua -- does not exist on
# this system (LoadState=not-found); UWSM owns the session.
#
# X-Restart-Triggers below exist because empty `settings` has a cost. sd-switch
# restarts a unit when the unit *definition* changes, and these units are just
# ExecStart=<binary> -- they never mention the config file. So editing a config
# here changed nothing sd-switch could see, and the daemon kept serving whatever
# it read at last login. mako ran three days on a stale default-timeout that way.
#
# Hashing the file rather than interpolating its path matters: dotfilesPath is
# inputs.self, so a path changes on every commit and would restart every daemon
# on every rebuild. The hash changes only when that config actually changes.
{ ... }:
{
  flake.modules.homeManager.session-services = { dotfilesPath, ... }: {
    # Idle: dim, lock, screen off, suspend. Config: .config/hypr/hypridle.conf
    services.hypridle.enable = true;

    # Wallpaper. Config: .config/hypr/hyprpaper.conf
    services.hyprpaper.enable = true;

    # Notifications. Config: .config/mako/
    services.mako.enable = true;

    # Bluetooth tray applet. The NixOS side (hardware.bluetooth, services.blueman)
    # lives in features/bluetooth/blueman.nix.
    services.blueman-applet.enable = true;

    systemd.user.services = {
      hypridle.Unit.X-Restart-Triggers = [
        (builtins.hashFile "sha256" "${dotfilesPath}/.config/hypr/hypridle.conf")
      ];

      mako.Unit.X-Restart-Triggers = [
        (builtins.hashFile "sha256" "${dotfilesPath}/.config/mako/config")
      ];

      # hyprpaper reads .config/hyprpaper/hyprpaper.conf, which symlinks.nix
      # points at .config/hypr/hyprpaper.conf -- hash the real source.
      hyprpaper.Unit.X-Restart-Triggers = [
        (builtins.hashFile "sha256" "${dotfilesPath}/.config/hypr/hyprpaper.conf")
      ];
    };
  };
}
