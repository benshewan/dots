_: {
  flake.modules.homeManager."programs/webstorm" = {pkgs, ...}: {
    home.packages = with pkgs; [
      (jetbrains.webstorm.override {
        vmopts = ''
          -Xmx4G
          -Xms2G
          -Dawt.toolkit.name=WLToolkit
        '';
      })
    ];
    # home.file.".config/JetBrains/prettier".source = pkgs.prettier;
  };
}
