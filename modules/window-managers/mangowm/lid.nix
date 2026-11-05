_: {
  flake.modules.homeManager."window-managers/mangowm" = {
    pkgs,
    lib,
    config,
    ...
  }: let
    mango = lib.getExe' config.wayland.windowManager.mango.package "mmsg";
    wlr-randr = lib.getExe pkgs.wlr-randr;
    jq = lib.getExe pkgs.jq;

    # Built-in panels come from the shared monitor list. `name` is the
    # wlr-randr connector, `spec` the MangoWM monitor spec ("name:eDP-1").
    internal =
      map (m: let
        parsed = config.lib.monitors.parseName m.name;
      in {
        name = parsed.value;
        spec = config.lib.monitors.mangoName m.name;
        inherit (m) x y width height scale;
      })
      (lib.filter (m: m.internal) config.monitors);

    lidState = pkgs.writeShellScript "mango-lid-state" ''
      for f in /proc/acpi/button/lid/*/state; do
        [ -r "$f" ] || continue
        case "$(cat "$f")" in
          *closed*) echo closed; exit 0 ;;
          *open*) echo open; exit 0 ;;
        esac
      done
      # No readable lid switch: treat the lid as open so we never hide a screen.
      echo open
    '';

    disableInternal = pkgs.writeShellScript "mango-lid-disable-internal" ''
      ${lib.concatMapStringsSep "\n" (m: ''
        ${mango} dispatch disable_monitor,"${m.spec}" || true
      '') internal}
    '';

    enableInternal = pkgs.writeShellScript "mango-lid-enable-internal" ''
      ${lib.concatMapStringsSep "\n" (m: ''
        ${wlr-randr} --output "${m.name}" --on --pos ${toString m.x},${toString m.y} --scale ${toString m.scale} --mode ${toString m.width}x${toString m.height} || true
      '') internal}
    '';

    # Bring the internal panel in line with the current lid state.
    apply = pkgs.writeShellScript "mango-lid-apply" ''
      if [ "$(${lidState})" = closed ]; then
        ${disableInternal}
      else
        ${enableInternal}
      fi
    '';

    # Wake every output after sleep, except the internal panel while the lid is
    # shut. MangoWM re-applies monitor_rule whenever outputs are reconfigured,
    # so the panel must be turned back off after they are enabled.
    wake = pkgs.writeShellScript "mango-lid-wake" ''
      lid=$(${lidState})
      ${wlr-randr} --json | ${jq} -r '.[].name' | while IFS= read -r output; do
        ${lib.optionalString (internal != []) ''
          case "$output" in
            ${lib.concatMapStringsSep "|" (m: m.name) internal})
              [ "$lid" = closed ] && continue
              ;;
          esac
        ''}
        ${mango} dispatch enable_monitor,"$output" || true
      done
      ${apply}
    '';

    # MangoWM only fires switchbind on a *change* of the lid switch, so nothing
    # happens after resuming with the lid already closed. Watch the monitor
    # list and re-hide the internal panel whenever it comes back (monitor_rule
    # is re-applied on hotplug/reload). Disabling only while another display is
    # on avoids leaving an undocked machine with no screen at all.
    guard = pkgs.writeShellScript "mango-lid-guard" ''
      ${apply}
      while :; do
        last=0
        while IFS= read -r snapshot; do
          ${lib.concatMapStringsSep "\n" (m: ''
            if echo "$snapshot" | ${jq} -e --arg name "${m.name}" \
                'any(.monitors[]; .name == $name and .width > 0)
                 and any(.monitors[]; .name != $name and .width > 0)' >/dev/null 2>&1; then
              [ "$(${lidState})" = closed ] || continue
              # Events arrive in bursts while outputs settle; one disable is
              # enough and repeated layout changes can disturb focus.
              if [ $((SECONDS - last)) -ge 1 ]; then
                ${mango} dispatch disable_monitor,"${m.spec}" >/dev/null 2>&1 || true
                last=$SECONDS
              fi
            fi
          '') internal}
        done < <(${mango} watch all-monitors)
        sleep 2
      done
    '';
  in {
    lib.mango.lid = {
      present = internal != [];
      inherit apply wake;
    };

    systemd.user.services.mango-lid-guard = lib.mkIf (internal != []) {
      Unit = {
        Description = "Hide the internal panel while the laptop lid is closed";
        After = ["mango-session.target"];
        PartOf = ["mango-session.target"];
      };
      Service = {
        ExecStart = guard;
        Restart = "always";
        RestartSec = 2;
      };
      Install.WantedBy = ["mango-session.target"];
    };
  };
}
