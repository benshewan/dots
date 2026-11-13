{config, ...}: let
  # Flake-level user metadata; config.flake does not exist inside the NixOS
  # module below, which shadows `config` with the host config.
  username = config.flake.meta.user.username;
  # Same default as modules.preservation, with an `or` so hosts without the
  # preservation import still evaluate.
  persistentPath = config.modules.preservation.persistentPath or "/persistent";
in {
  flake.modules.nixos."display-managers/auto-login" = {
    config,
    lib,
    pkgs,
    ...
  }: let
    cfg = config.modules.displayManager.autoLogin;
  in {
    options.modules.displayManager.autoLogin = {
      enable = lib.mkEnableOption ''
        boot straight into the graphical session with greetd's
        initial_session, skipping any login prompt or greeter. Intended for
        testing VMs (caelum); the session restarts through the default
        greeter after logout.
      '';

      command = lib.mkOption {
        type = lib.types.str;
        description = ''
          Compositor command line for the auto-login session, without a
          session bus (the module runs it under dbus-run-session). Set
          XDG_CURRENT_DESKTOP here so portals pick the right backends, e.g.
          `env XDG_CURRENT_DESKTOP=mango:wlroots <compositor>`.
        '';
      };
    };

    config = lib.mkIf cfg.enable {
      # Replace the sddm greeter imported by the window-manager preset: two
      # display managers would both fight for the tty at boot.
      services.displayManager.sddm.enable = lib.mkForce false;
      programs.silentSDDM.enable = lib.mkForce false;

      # Needed for the fallback greeter to find the compositor's desktop
      # entry (the display-manager machinery that normally does this is
      # disabled together with sddm).
      environment.pathsToLink = ["/share/wayland-sessions"];

      # Auto-login cannot unlock a passworded keyring: pam_gnome_keyring has
      # no password to feed it (Arch wiki "PAM step", GNOME bug 506356), so
      # the login keyring must be blank-password. A blank keyring is a plain
      # INI file which the daemon auto-opens at startup, and the seed below
      # creates it only when missing (`f` never overwrites an existing
      # keyring). The contents are unencrypted, but they sit inside the
      # LUKS2 volume — acceptable for a testing VM. The \n escapes keep the
      # tmpfiles rule on one line; systemd-tmpfiles expands them into the
      # file.
      systemd.tmpfiles.rules = [
        "f ${persistentPath}/home/${username}/.local/share/keyrings/login.keyring 0600 ${username} users - [keyring]\ndisplay-name=login\nctime=0\nmtime=0\nlock-on-idle=false\nlock-after=false\n"
      ];

      # Even with a blank keyring the PAM-started daemon (no password to
      # feed it) leaves the keyring locked at boot; one Unlock call opens
      # blank keyrings without any interaction. Runs after the graphical
      # session is up, once.
      systemd.user.services."keyring-autounlock" = {
        description = "Unlock the (blank) default keyring after auto-login";
        wantedBy = ["graphical-session.target"];
        after = ["graphical-session.target"];
        script = ''
          export DBUS_SESSION_BUS_ADDRESS=unix:path=$XDG_RUNTIME_DIR/bus
          # The unit PATH has no /run/current-system/sw/bin: absolute
          # busctl, and shell expansion instead of tr/awk. Retry: the
          # PAM-started daemon may not own its bus name yet when the
          # graphical session targets come up.
          tries=0
          until out=$(/run/current-system/sw/bin/busctl --user call org.gnome.keyring /org/freedesktop/secrets org.freedesktop.Secret.Service Unlock ao 1 /org/freedesktop/secrets/collection/login 2>/dev/null); do
            tries=$((tries + 1))
            if [ "$tries" -ge 30 ]; then
              echo "keyring never appeared on the bus"
              exit 1
            fi
            sleep 0.5
          done
          prompt=''${out##* }
          prompt=''${prompt//\"/}
          if [ "$prompt" != "/" ]; then
            /run/current-system/sw/bin/busctl --user call org.gnome.keyring "$prompt" org.freedesktop.Secret.Prompt Prompt s ""
            sleep 1
          fi
        '';
        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
        };
      };

      services.greetd = {
        enable = true;
        # greetd REQUIRES default_session to carry a command: without one it
        # exits with "default_session contains no command" at boot and the
        # initial session never starts. tuigreet is the recovery path a
        # session returns to after logout.
        settings = {
          default_session = {
            user = "greeter";
            command = "${pkgs.tuigreet}/bin/tuigreet --time --remember";
          };
          initial_session = {
            # greetd's config key is `user`, not `username` — `inherit
            # username` produced a key greetd ignores and greetd failed
            # with "initial_session contains no user".
            user = username;
            command = "dbus-run-session -- ${cfg.command}";
          };
        };
      };
    };
  };
}
