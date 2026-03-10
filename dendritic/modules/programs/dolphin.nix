_: {
  flake.modules.homeManager."programs/dolphin" = {pkgs, ...}: {
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
        PartOf = ["graphical-session.target"];
      };
      Install = {
        WantedBy = ["graphical-session.target"];
      };
      Service = {
        # NixOS typically places baloo_file in the libexec directory
        ExecStart = "${pkgs.kdePackages.baloo}/libexec/baloo_file";
        Restart = "on-failure";
      };
    };
  };
}
