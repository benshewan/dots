{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    (vivaldi.override {
      proprietaryCodecs = true; # causes some crashes with certain video sites
      enableWidevine = true;
      commandLineArgs = "--enable-features=WebUIDarkMode --force-dark-mode --ozone-platform-hint=auto --gtk-version=4";
    })
  ];

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
}
