{
  pkgs,
  config,
  lib,
  ...
}: let
  cfg = config.night-sky.programs;
in {
  options.night-sky.programs = {
    chromium.enable = lib.mkEnableOption "chromium";
    vivaldi.enable = lib.mkEnableOption "vivaldi";
  };

  config = lib.mkMerge [
    (lib.mkIf (cfg.chromium.enable || cfg.vivaldi.enable) {
      programs.chromium = {
        enable = true;
        enablePlasmaBrowserIntegration = true;
        extensions = [
          "cjpalhdlnbpafiamejdnhcphjbkeiagm" # uBlock Origin
          # "eimadpbcbfnmbkopoojfekhnkhdbieeh" # Dark Reader
          "nngceckbapebfimnlniiiahkandclblb" # Bitwarden
          # "pnidmkljnhbjfffciajlcpeldoljnidn" # Linkwarden
          "mnjggcdmjocbbbhaepdhchncahnbgone" # SponsorBlock
          "gbmdgpbipfallnflgajpaliibnhdgobh" # JSON Viewer
          "cimiefiiaegbelhefglklhhakcgmhkai" # KDE Connect
          # "dbepggeogbaibhgnhhndojpepiihcmeb" # Vimium
          "kbmfpngjjgdllneeigpgjifpgocmfgmb" # Reddit Enhancement Suite
          "oabphaconndgibllomdcjbfdghcmenci" # Remote Torrent Adder
          "lkbebcjgcmobigpeffafkodonchffocl;https://gitlab.com/magnolia1234/bypass-paywalls-chrome-clean/-/raw/master/updates.xml" # Bypass Paywalls

          # Dev Stuff
          "lmhkpmbekcpmknklioeibfkpmmfibljd" # Redux Dev Tools
          "fmkadmapgofadopljbjfkapdkoienihi" # React Dev Tools
        ];
        extraOpts = {
          BrowserSignin = 1;
          SyncDisabled = false;
          PasswordManagerEnabled = false;
          SpellcheckEnabled = true;
          EnableMediaRouter = false;
        };
      };
    })

    (lib.mkIf cfg.vivaldi.enable {
      environment.systemPackages = with pkgs; [
        (vivaldi.override {
          proprietaryCodecs = true;
          enableWidevine = true;
          commandLineArgs = "--enable-features=WebUIDarkMode --force-dark-mode --ozone-platform-hint=auto --gtk-version=4 --enable-features=PlatformHEVCDecoderSupport";
        })
      ];
    })
  ];
}
