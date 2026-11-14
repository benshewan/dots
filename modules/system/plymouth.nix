_: {
  # Plymouth splash, boot and shutdown. Resolved as `system/plymouth` (the
  # desktop preset pulls it in; core.nix provides the silence around it:
  # kernelParams quiet + consoleLogLevel = 0).
  flake.modules.nixos."system/plymouth" = {
    lib,
    config,
    pkgs,
    ...
  }: let
    # Shutdown splash. The shipped plymouth-{reboot,poweroff} units start
    # `plymouthd --mode=...` but chain their After= through
    # systemd-user-sessions -> plymouth-quit -> plymouth-start, which stop
    # LAST — the splash only appeared in the final second of the cascade.
    # Drop-ins cannot fix this (systemd merges After= additively), so the
    # shipped units are masked (see systemd.units below) and replaced by
    # these. `ply` ordering note: plymouthd opens /dev/dri directly and needs
    # drmSetMaster — the kernel allows exactly one master, so the units MUST
    # wait for display-manager.service (sddm stops early in the reverse-order
    # cascade and the user session dies with it), but must NOT wait for
    # plymouth-start.service.
    mkShutdownUnit = mode: let
      lower = lib.toLower mode;
    in {
      name = "plymouth-shutdown-${lower}";
      value = {
        description = "Show Plymouth ${mode} Screen";
        wantedBy = ["${lower}.target"];
        before = ["shutdown.target" "systemd-${lower}.service"];
        after = ["display-manager.service"];
        unitConfig = {
          DefaultDependencies = false;
          ConditionKernelCommandLine = "!plymouth.enable=0";
          ConditionVirtualization = "!container";
        };
        serviceConfig = {
          Type = "forking";
          ExecStart = "${config.boot.plymouth.package}/sbin/plymouthd --mode=${lower} --attach-to-session";
          ExecStartPost = "-${config.boot.plymouth.package}/bin/plymouth show-splash";
          RemainAfterExit = true;
        };
      };
    };
  in {
    boot.plymouth.enable = true; # upstream module also adds the `splash` param

    # Hide the blinking cursor on the text consoles: it is visible in the
    # instant between the compositor exiting and the splash taking over, both
    # at boot and at shutdown. Tradeoff: real ttys (Ctrl+Alt+F-keys) have no
    # cursor either.
    boot.kernelParams = ["vt.global_cursor_default=0"];

    # The shipped units cannot be reordered in place (see above) — mask them.
    systemd.units = {
      "plymouth-reboot.service".enable = lib.mkForce false;
      "plymouth-poweroff.service".enable = lib.mkForce false;
    };

    systemd.services =
      lib.listToAttrs (map mkShutdownUnit ["Reboot" "Poweroff"])
      // {
        # Switch the console away from the session VT the moment a
        # shutdown/reboot is queued. logind's wall broadcast ("The system
        # will reboot now!") is written to the session's tty at request time;
        # when the compositor exits, the framebuffer console shows that tty's
        # buffer — a flicker of text before the splash renders. This unit
        # runs before the compositor dies, so the console shows a blank VT
        # instead. (The wall broadcast cannot be suppressed: logind's
        # EnableWallMessages property is inert for delivery in this systemd
        # build, verified empirically.) Degrades to the stock flicker if
        # chvt fails.
        "plymouth-shutdown-vt" = {
          description = "Move console off the session VT for the shutdown splash";
          wantedBy = ["reboot.target" "poweroff.target"];
          before = ["shutdown.target"];
          unitConfig = {
            DefaultDependencies = false;
            ConditionKernelCommandLine = "!plymouth.enable=0";
          };
          serviceConfig = {
            Type = "oneshot";
            ExecStart = "${pkgs.kbd}/bin/chvt 12";
          };
        };

        # Hand plymouth to the shutdown ramfs (nixpkgs#191620): NixOS only
        # wires this shipped unit into the initrd; enable it in stage 2,
        # ordered after the NixOS name of the shutdown-ramfs generator (the
        # upstream unit only lists mkinitcpio-generate-shutdown-ramfs.service)
        # and after our replacement splash units.
        plymouth-switch-root-initramfs = {
          wantedBy = ["reboot.target" "poweroff.target" "halt.target" "kexec.target"];
          after = [
            "generate-shutdown-ramfs.service"
            "plymouth-shutdown-reboot.service"
            "plymouth-shutdown-poweroff.service"
          ];
        };

        # Belt-and-braces for a future systemd that honours the property:
        # there is no logind.conf knob for wall messages, so flip the runtime
        # property right after logind reports READY (Type=notify-reload, so
        # ExecStartPost runs with the D-Bus name already up, and re-runs if
        # logind restarts). Single-user machine: nobody to broadcast to.
        systemd-logind.serviceConfig.ExecStartPost = "${config.systemd.package}/bin/busctl set-property org.freedesktop.login1 /org/freedesktop/login1 org.freedesktop.login1.Manager EnableWallMessages b false";
      };

    # Without plymouthd-fd-escrow in the shutdown ramfs, plymouthd dies in the
    # shutdown kill spree and the splash vanishes while systemd-shutdown
    # prints to the tty (nixpkgs#191620; upstream PR #573463 not merged). The
    # escrow helper holds the DRM file descriptor and keeps the last frame on
    # screen through the final pivot.
    systemd.shutdownRamfs.storePaths = [
      "${config.boot.plymouth.package}/libexec/plymouth/plymouthd-fd-escrow"
    ];
  };
}
