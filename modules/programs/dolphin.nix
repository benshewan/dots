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
}
