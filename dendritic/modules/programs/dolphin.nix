_: {
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
    systemd.user.services.baloo = {
      Unit = {
        Description = "Baloo File Indexer Daemon";
        # Ensure it waits for the graphical session and dbus to be fully up
        After = ["graphical-session.target"];
        PartOf = ["graphical-session.target"];
      };
      Install = {
        WantedBy = ["graphical-session.target"];
      };
      Service = {
        Type = "oneshot";
        RemainAfterExit = true;
        # Using lib.getExe handles the exact path to the binary automatically.
        # Note: If your NixOS channel uses balooctl6, change the string to "balooctl6"
        ExecStart = "${lib.getExe' pkgs.kdePackages.baloo "balooctl6"} start";
        ExecStop = "${lib.getExe' pkgs.kdePackages.baloo "balooctl6"} suspend";
      };
    };
  };
}
