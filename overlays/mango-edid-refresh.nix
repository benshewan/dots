# MangoWM keeps the wrong monitor identity after resuming from suspend.
#
# Both external monitors hang off a DP-MST hub (CalDigit TS4). On resume the
# hub reprobes its topology and re-associates the sinks with other hub ports
# while the kernel keeps reporting the connectors as connected. wlroots only
# reads a connector's EDID and mode list on a DISCONNECTED -> CONNECTED
# transition, so each output kept the pre-suspend make/model/serial and mode
# list. MangoWM matches `monitor_rule` by `serial:`, so the Dell AW3423DWF was
# given the P24q-10 rule and vice versa (the 24" panel was fed 3440x1440@165
# and stayed black).
#
# The patch refreshes the cached EDID identity on every connector scan and
# re-creates the output when it changed, which makes MangoWM re-apply the
# correct rule on resume. See patches/wlroots-drm-refresh-edid-on-scan.patch
# and https://gitlab.freedesktop.org/wlroots/wlroots/-/issues/1807.
{inputs, ...}: final: prev: let
  inherit (prev.stdenv.hostPlatform) system;

  wlroots = prev.wlroots_0_20.overrideAttrs (old: {
    patches = (old.patches or []) ++ [../patches/wlroots-drm-refresh-edid-on-scan.patch];
  });
in
  prev.lib.optionalAttrs prev.stdenv.hostPlatform.isLinux {
    # Patched wlroots, exposed separately so the stock one (and anything else
    # linking against it) stays untouched.
    wlroots-edid-refresh = wlroots;

    # inputs.mangowm already follows this flake's nixpkgs, so the only thing to
    # replace is the wlroots input: scenefx, xwayland, etc. keep coming from
    # the same package set the mangowm flake pins.
    mango-edid-refresh =
      inputs.mangowm.packages.${system}.mango.override {wlroots_0_20 = wlroots;};
  }
