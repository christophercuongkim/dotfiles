# wayvnc — on-demand VNC into the live Hyprland session over Tailscale
#
# Two on-demand user services (neither auto-starts). Pick one:
#
#   systemctl --user start wayvnc            # plain: mirror the active output
#   systemctl --user start wayvnc-headless   # headless: virtual output,
#                                            #   laptop panel goes dark
#   systemctl --user stop  wayvnc[-headless] # stop (headless restores eDP-1)
#
# They both bind :5900 and are marked Conflicts=, so starting one stops the
# other. Then from another tailnet device point any VNC viewer at
#   <AppleII-tailscale-ip>:5900
#
# Security: reachable ONLY over the tailnet. The firewall default-denies and
# trusts only tailscale0 (see firewall.nix); 5900 is not in allowedTCPPorts,
# so binding 0.0.0.0 exposes it to the tailnet and nothing else. Tailscale
# already authenticates the device and encrypts the transport (WireGuard),
# so no extra VNC TLS/password layer is configured.
{ ... }:
{
  # System side: make the wayvnc binary available.
  flake.modules.nixos.wayvnc = { pkgs, ... }: {
    environment.systemPackages = [ pkgs.wayvnc ];
  };

  # User side: two on-demand systemd user services. No [Install]/WantedBy, so
  # neither starts on its own — only via `systemctl --user start ...`.
  flake.modules.homeManager.wayvnc =
    { pkgs, ... }:
    let
      wayvnc-headless = pkgs.writeShellApplication {
        name = "wayvnc-headless";
        runtimeInputs = [
          pkgs.wayvnc
          pkgs.hyprland # hyprctl
          pkgs.jq
          pkgs.coreutils
        ];
        text = ''
          # Create a virtual headless output, disable the physical panel, and
          # serve the virtual output over VNC. Lets us drive the session with
          # the laptop screen fully dark and no monitor attached. On exit we
          # remove the virtual output and `hyprctl reload` to restore eDP-1
          # from monitors.lua.
          #
          # Order matters: create the headless output BEFORE disabling eDP-1,
          # so eDP-1 is never the sole output (disabling the sole output leaves
          # it black on the next lid-open — see monitors.lua).
          before=$(hyprctl monitors all -j | jq -r '.[].name' | sort)
          hyprctl output create headless
          sleep 0.3
          after=$(hyprctl monitors all -j | jq -r '.[].name' | sort)
          out=$(comm -13 <(echo "$before") <(echo "$after") | head -1)
          if [ -z "$out" ]; then
            echo "wayvnc-headless: failed to create headless output" >&2
            exit 1
          fi
          # hyprctl keyword is a no-op under a Lua config; use eval.
          hyprctl eval "hl.monitor({ output = '$out', mode = '1920x1080@60', position = 'auto', scale = 1 })"
          hyprctl eval "hl.monitor({ output = 'eDP-1', disabled = true })"

          cleanup() {
            [ -n "''${child:-}" ] && kill "$child" 2>/dev/null || true
            hyprctl output remove "$out" 2>/dev/null || true
            hyprctl reload 2>/dev/null || true # restore eDP-1 from monitors.lua
          }
          trap 'exit 0' INT TERM
          trap cleanup EXIT

          wayvnc -o "$out" 0.0.0.0 5900 &
          child=$!
          wait "$child"
        '';
      };

      commonUnit = {
        After = [ "graphical-session.target" ];
        PartOf = [ "graphical-session.target" ];
      };
    in
    {
      # Plain: mirror whatever output is currently active. No monitor changes.
      systemd.user.services.wayvnc = {
        Unit = commonUnit // {
          Description = "On-demand wayvnc (active output) over Tailscale";
          Conflicts = [ "wayvnc-headless.service" ];
        };
        Service = {
          ExecStart = "${pkgs.wayvnc}/bin/wayvnc 0.0.0.0 5900";
          Restart = "no";
        };
        # Deliberately no Install/WantedBy: manual start only.
      };

      # Headless: virtual output + physical panel off; restores on stop.
      systemd.user.services.wayvnc-headless = {
        Unit = commonUnit // {
          Description = "On-demand wayvnc (headless output, panel off) over Tailscale";
          Conflicts = [ "wayvnc.service" ];
        };
        Service = {
          ExecStart = "${wayvnc-headless}/bin/wayvnc-headless";
          Restart = "no";
        };
        # Deliberately no Install/WantedBy: manual start only.
      };
    };
}
