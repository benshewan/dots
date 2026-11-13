{config, ...}: let
  username = config.flake.meta.user.username;
in {
  flake.modules.homeManager."programs/brave" = {
    pkgs,
    config,
    lib,
    ...
  }: let
    # brave was REMOVED from nixpkgs unstable (no maintainer to unblock
    # security fixes); pulled from the stable branch until a replacement
    # (or its return) happens.
    brave = pkgs.stable.brave;
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
      package = brave;
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

  # Preservation companion for "programs/brave" (auto-resolved by the
  # prefix). Whole Chromium profile dir, same rationale as chromium:
  # Brave-Browser/Default (bookmarks, passwords, history, Local Storage
  # LevelDB) plus Local State. HM's mergeBraveSettings activation writes
  # Preferences.json INSIDE the mount each activation.
  flake.modules.nixos."preservation/programs/brave" = {config, ...}: {
    preservation.preserveAt.${config.modules.preservation.persistentPath}.users.${username} = {
      directories = [
        ".config/BraveSoftware"
      ];
    };
  };
}
