_: {
  flake.modules.homeManager."programs/vivaldi" = {
    pkgs,
    config,
    ...
  }: let
    phi-theme = pkgs.fetchFromGitHub {
      owner = "KaKi87";
      repo = "phi-for-vivaldi";
      rev = "848a8ae318b524c0a7cf0e240c0fa9b6cf8f9ce1";
      sha256 = "sha256-UAFS/L4OhpinQhxX1XmrIeOD1/TeHDGI/w3WX6CuKJY=";
    };
  in {
    programs.vivaldi = {
      enable = true;
      package = pkgs.vivaldi.override {
        proprietaryCodecs = true;
        enableWidevine = true;
      };
      nativeMessagingHosts = [
        pkgs.kdePackages.plasma-browser-integration
      ];
      extensions = [
        {id = "ddkjiahejlhfcafbddmgiahcphecmpfh";} # uBlock Origin Lite
        {id = "nngceckbapebfimnlniiiahkandclblb";} # Bitwarden
        {id = "mnjggcdmjocbbbhaepdhchncahnbgone";} # SponsorBlock
        {id = "ponfpcnoihfmfllpaingbgckeeldkhle";} # Enhancer for YouTube
        {id = "gbmdgpbipfallnflgajpaliibnhdgobh";} # JSON Viewer
        {id = "cimiefiiaegbelhefglklhhakcgmhkai";} # KDE Connect
        {id = "kbmfpngjjgdllneeigpgjifpgocmfgmb";} # Reddit Enhancement Suite
        # {
        #   id = "lkbebcjgcmobigpeffafkodonchffocl"; # Bypass Paywalls
        #   updateUrl = "https://gitlab.com/magnolia1234/bypass-paywalls-chrome-clean/-/raw/master/updates.xml";
        # }
        # {id = "lmhkpmbekcpmknklioeibfkpmmfibljd";} # Redux Dev Tools
        # {id = "fmkadmapgofadopljbjfkapdkoienihi";} # React Dev Tools
      ];
    };
    home.file.".config/vivaldi/theme/phi.css".source = "${phi-theme}/phi.css";
    home.file.".config/vivaldi/theme/phi-settings.css".text = ''
      body
      {
          --phi--sidebar-width: 210;
          --phi--compact-sidebar-width: 50;
          --phi--is-auto-compact-mode: 0;
          --phi--is-phi-menu-icon: 1;
          --phi--toolbar-column-count: 5;
          --phi--address-bar-focused-width-increase: 200;
          --phi--address-bar-font-size-decrease: 1;
          --phi--is-address-bar-focused-height-increase: 1;
          --phi--is-address-bar-unfocused-partial: 0;
          --phi--is-address-bar-unfocused-hide-icons: 1;
          --phi--is-address-bar-focused-hide-icons: 0;
          --phi--pinned-column-count: 4;
          --phi--webview-border: 0;
          --phi--webview-border-radius: 0;
          --phi--webview-shadow-size: 0;
          --phi--webview-shadow-color: 0, 0, 0, 0.25;
          --phi--is-individual-tiled-tab-header: 0;
          --phi--is-hide-window-controls: 0;
          --phi--is-hide-content-blocker: 1;
      }
    '';
  };
}
