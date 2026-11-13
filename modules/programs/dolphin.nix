{config, ...}: let
  # Flake-level user metadata; config.flake does not exist inside NixOS
  # modules, which shadow `config` with the host config.
  username = config.flake.meta.user.username;
in {
  flake.modules.homeManager."programs/dolphin" = {
    pkgs,
    lib,
    ...
  }: {
    home.packages =
      (with pkgs; [
        taglib
        ffmpegthumbnailer
      ])
      ++ (with pkgs.kdePackages; [
        dolphin
        ark
        baloo
        dolphin-plugins
        kdegraphics-thumbnailers
        kio
        kio-extras
        breeze-icons
      ]);
    # maybe add  to baloorc file instead?
    # [Basic Settings]
    # Indexing-Enabled=true
    # systemd.user.services.baloo = {
    #   Unit = {
    #     Description = "Baloo File Indexer Daemon";
    #     After = ["graphical-session.target"];
    #     PartOf = ["graphical-session.target"];
    #   };
    #   Install = {
    #     WantedBy = ["graphical-session.target"];
    #   };
    #   Service = {
    #     Type = "oneshot";
    #     RemainAfterExit = true;
    #     ExecStart = "${lib.getExe' pkgs.kdePackages.baloo "balooctl6"} enable";
    #     ExecStop = "${lib.getExe' pkgs.kdePackages.baloo "balooctl6"} suspend";
    #   };
    # };
  };

  # Preservation companion for "programs/dolphin" (auto-resolved by the prefix).
  # NOTE: ~/.config/dolphinrc is deliberately NOT preserved. KConfig saves
  # atomically (temp file + rename(2) onto the target), and rename onto a
  # preservation file bind mount fails with EBUSY — the write is swallowed
  # silently (verified with strace), so a file mount would freeze the
  # config at its seeded defaults forever. The symlink method loses updates
  # at the same rename. View settings reset each boot; the durable state
  # (bookmarks, recent files) lives under .local/share/dolphin.
  flake.modules.nixos."preservation/programs/dolphin" = {config, ...}: {
    preservation.preserveAt.${config.modules.preservation.persistentPath}.users.${username} = {
      directories = [
        # Bookmarks, recent files and search state.
        ".local/share/dolphin"
      ];
    };
  };
}
