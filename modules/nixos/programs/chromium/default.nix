{
  pkgs,
  config,
  lib,
  ...
}: let
  cfg = config.night-sky.programs.chromium;
in {
  options.night-sky.programs.chromium = {
    enable = lib.mkEnableOption "chromium";
  };

  config = lib.mkIf cfg.enable {
    programs.chromium = {
      enable = true;
      enablePlasmaBrowserIntegration = true;
      extensions = [
        "cjpalhdlnbpafiamejdnhcphjbkeiagm" # uBlock Origin
        "eimadpbcbfnmbkopoojfekhnkhdbieeh" # Dark Reader
        "nngceckbapebfimnlniiiahkandclblb" # Bitwarden
        "pnidmkljnhbjfffciajlcpeldoljnidn" # Linkwarden
        "mnjggcdmjocbbbhaepdhchncahnbgone" # SponsorBlock
        "gbmdgpbipfallnflgajpaliibnhdgobh" # JSON Viewer
        "dnnckbejblnejeabhcmhklcaljjpdjeh" # KDE Connect
        "dbepggeogbaibhgnhhndojpepiihcmeb" # Vimium
        "lkbebcjgcmobigpeffafkodonchffocl;https://gitlab.com/magnolia1234/bypass-paywalls-chrome-clean/-/raw/master/updates.xml"
      ];
      extraOpts = {
        BrowserSignin = 1;
        SyncDisabled = false;
        PasswordManagerEnabled = false;
        SpellcheckEnabled = true;
        EnableMediaRouter = false;
      };
    };
  };
}
