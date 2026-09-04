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
{ ... }:
{
  flake.modules.homeManager.session-services = {
    # Idle: dim, lock, screen off, suspend. Config: .config/hypr/hypridle.conf
    services.hypridle.enable = true;

    # Wallpaper. Config: .config/hypr/hyprpaper.conf
    services.hyprpaper.enable = true;

    # Notifications. Config: .config/mako/
    services.mako.enable = true;

    # Bluetooth tray applet. The NixOS side (hardware.bluetooth, services.blueman)
    # lives in features/bluetooth/blueman.nix.
    services.blueman-applet.enable = true;
  };
}
