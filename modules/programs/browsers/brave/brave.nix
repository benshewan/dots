_: {
  flake.modules.homeManager."programs/brave" = {
    pkgs,
    config,
    lib,
    ...
  }: let
    mergeScript = pkgs.runCommand "brave-merge-prefs.sh" {} ''
      cp ${./merge-prefs.sh} $out
      chmod +x $out
    '';
  in {
    home.activation.mergeBraveSettings = lib.hm.dag.entryAfter ["writeBoundary"] ''
      ${mergeScript} ${pkgs.jq}/bin/jq '${./Preferences.json}' '${config.home.homeDirectory}/.config/BraveSoftware/Brave-Browser/Default/Preferences'
    '';
    programs.brave = {
      enable = true;
      package = pkgs.brave;
      nativeMessagingHosts = [
        pkgs.kdePackages.plasma-browser-integration
      ];
      extensions = [
        {id = "nngceckbapebfimnlniiiahkandclblb";} # Bitwarden
        {id = "mnjggcdmjocbbbhaepdhchncahnbgone";} # SponsorBlock
        {id = "ponfpcnoihfmfllpaingbgckeeldkhle";} # Enhancer for YouTube
        {id = "gbmdgpbipfallnflgajpaliibnhdgobh";} # JSON Viewer
        {id = "cimiefiiaegbelhefglklhhakcgmhkai";} # KDE Connect
        {id = "kbmfpngjjgdllneeigpgjifpgocmfgmb";} # Reddit Enhancement Suite
        # {id = "lmhkpmbekcpmknklioeibfkpmmfibljd";} # Redux Dev Tools
        # {id = "fmkadmapgofadopljbjfkapdkoienihi";} # React Dev Tools
      ];
    };
  };
  flake.modules.nixos."programs/brave" = {
    environment.etc."/brave/policies/managed/GroupPolicy.json".source = ./GroupPolicy.json;
  };
}
