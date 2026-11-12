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
            # journald, coredumps and systemd bookkeeping
            "/var/log"
            {
              directory = "/var/lib/nixos";
              inInitrd = true;
            }
            "/var/lib/systemd/coredump"
            "/var/lib/systemd/rfkill"
            "/var/lib/systemd/timers"

            # State of services running with DynamicUser=yes
            {
              directory = "/var/lib/private";
              mode = "0700";
            }

            # Per-device backlight levels restored by systemd-backlight.
            "/var/lib/systemd/backlight"
          ];

          files = [
            # Machine identity, needed before sysinit.
            {
              file = "/etc/machine-id";
              inInitrd = true;
            }

            # Written lazily by systemd-timedated, so symlink instead of
            # bind-mounting (the target must not exist before initialization).
            {
              file = "/etc/adjtime";
              how = "symlink";
            }

            # Boot-time RNG state; upstream docs recommend a symlink in the
            # initrd so the file is created directly on persistent storage.
            {
              file = "/var/lib/systemd/random-seed";
              how = "symlink";
              inInitrd = true;
            }
          ];
        };
      };
    };
  };
}
