{inputs, ...}: {
  flake-file.inputs.preservation = {
    url = "github:nix-community/preservation";
  };

  # Declarative, systemd-native state persistence (an "interpreter-less"
  # alternative to impermanence). It generates tmpfiles.d rules and mount units,
  # so state is bind-mounted or symlinked back into place before sysinit.
  #
  # Usage from a host:
  #
  #   imports = config.flake.lib.resolve [ "preservation" ];
  #   modules.preservation.enable = true;
  #
  # Only state that is owned by the OS itself lives below. Anything owned by a
  # service belongs in that service's own module file, as a companion module
  # named `preservation/<feature>` (e.g. `preservation/services/ssh` in
  # modules/services/ssh.nix). `config.flake.lib.resolve` imports companions
  # automatically when their base module is loaded.
  #
  # Enabling this does not make the root filesystem volatile by itself. Pair it
  # with a tmpfs root (or a wiped btrfs/zfs snapshot) and declare a real
  # filesystem at modules.preservation.persistentPath with `neededForBoot =
  # true` to get erase-your-darlings behaviour. Existing state must be moved
  # there manually before the first boot:
  #
  #   sudo rsync -aAXH /var/lib/nixos/ /persistent/var/lib/nixos/
  flake.modules.nixos.preservation = {
    config,
    lib,
    pkgs,
    ...
  }: let
    cfg = config.modules.preservation;
  in {
    imports = [inputs.preservation.nixosModules.preservation];

    options.modules.preservation = {
      enable = lib.mkEnableOption "declarative state persistence with preservation";

      persistentPath = lib.mkOption {
        type = lib.types.str;
        default = "/persistent";
        description = "Mount point that stores preserved state.";
      };
    };

    config = lib.mkIf cfg.enable {
      # Every path may only be declared for preservation once: two declarations
      # can carry different `mode` values, and the resulting conflicting
      # tmpfiles rules fail the evaluation (see nix-community/preservation#20).
      assertions = let
        preservedPaths =
          lib.concatMap
          (
            root:
              map (d: d.directory or d) root.directories
              ++ map (f: f.file) root.files
              ++ lib.concatLists (
                lib.mapAttrsToList
                (
                  user: u:
                    map (d: "${user}:${d.directory or d}") u.directories
                    ++ map (f: "${user}:${f.file}") u.files
                )
                root.users
              )
          )
          (lib.attrValues config.preservation.preserveAt);
        duplicates = lib.filterAttrs (_: n: n > 1) (
          builtins.foldl'
          (acc: p: acc // {${p} = (acc.${p} or 0) + 1;})
          {}
          preservedPaths
        );
      in [
        {
          assertion = duplicates == {};
          message =
            "modules.preservation: the following paths are declared for "
            + "preservation more than once, which yields conflicting tmpfiles "
            + "rules. Each path must be owned by exactly one companion module: "
            + lib.concatStringsSep ", " (lib.attrNames duplicates);
        }
      ];

      # Everything preserved is mounted from this path during early boot, so its
      # filesystem has to be available in the initrd. The filesystem itself is
      # declared by the host (or disko); it must set `neededForBoot = true`.
      warnings =
        lib.optional (!(config.fileSystems ? ${cfg.persistentPath})) ''
          modules.preservation: no fileSystems entry is declared for
          ${cfg.persistentPath}. Preserved state will only survive reboots if
          that path is already persistent (for example when it lives on the root
          filesystem).
        ''
        ++ lib.optional (
          (config.fileSystems ? ${cfg.persistentPath})
          && !config.fileSystems.${cfg.persistentPath}.neededForBoot
        ) ''
          modules.preservation: fileSystems.${cfg.persistentPath} is not marked
          `neededForBoot = true`, so it may not be mounted when preservation
          bind-mounts state from it during early boot.
        '';

      # Conflicts with a bind-mounted /etc/machine-id, which is preserved below.
      systemd.suppressedSystemUnits = ["systemd-machine-id-commit.service"];

      preservation = {
        enable = true;
        preserveAt.${cfg.persistentPath} = {
          directories = [
            # Journal, boot log and accounting records.
            "/var/log"
            # UID/GID assignments and rebuild bookkeeping.
            {
              directory = "/var/lib/nixos";
              inInitrd = true;
            }
            # systemd's own state, preserved wholesale. The nixpkgs systemd
            # state manual recommends the whole directory because the
            # interesting subdirs (random-seed, timers, coredump, rfkill,
            # backlight, timesyncd clock, linger, credential.secret, ...) are
            # "not meant to be exhaustive". One initrd bind mount covers all
            # of them plus anything upstream adds, so random-seed and
            # credential.secret no longer need their own file rules: they are
            # created directly on persistent storage (systemd-creds setup
            # refuses to replace an invalid file, which its tmpfiles rule for
            # credential.secret would have created). catalog/ and
            # ephemeral-trees/ come along too; the latter is wiped every boot
            # by systemd's own tmpfiles rule (age 0) anyway.
            {
              directory = "/var/lib/systemd";
              inInitrd = true;
            }
            # State of DynamicUser services.
            {
              directory = "/var/lib/private";
              mode = "0700";
            }
            # Last-login records.
            "/var/lib/lastlog"
          ];

          files = [
            # Machine identity.
            {
              file = "/etc/machine-id";
              inInitrd = true;
            }
            # Clock drift and UTC flag, written lazily by systemd-timedated.
            {
              file = "/etc/adjtime";
              how = "symlink";
            }
          ];
        };
      };

      # Older revisions of the LUKS layout created the persistent parent with
      # mode 0700 (pcrlock.json privacy). Bind-mounted wholesale that mode
      # becomes /var/lib/systemd itself and breaks the non-root writers below
      # it: systemd-timesyncd owns timesync/, systemd-coredump saves dumps
      # into coredump/. systemd's own tmpfiles rule (systemd.conf) wants 0755,
      # so match it. `d` rules only apply mode when creating the directory,
      # hence the explicit fix for existing volumes; fresh installs get 0755
      # from the preservation tmpfiles rules directly.
      system.activationScripts.preservation-systemd-dir-mode = ''
        if [ -d ${cfg.persistentPath}/var/lib/systemd ]; then
          ${pkgs.coreutils}/bin/chmod 0755 ${cfg.persistentPath}/var/lib/systemd
        fi
      '';

      # logrotate atomically renames its state file, which fails on a bind mount
      # (EBUSY); point it at the persistent path instead.
      services.logrotate.extraArgs = ["--state" "${cfg.persistentPath}/var/lib/logrotate.status"];
    };
  };
}
