{pkgs, ...}: {
  environment.systemPackages = [
  ];

  programs.chromium = {
    enable = true;
    extensions = [
      "cjpalhdlnbpafiamejdnhcphjbkeiagm" # uBlock Origin
      "eimadpbcbfnmbkopoojfekhnkhdbieeh" # Dark Reader
      "nngceckbapebfimnlniiiahkandclblb" # Bitwarden
      "mnjggcdmjocbbbhaepdhchncahnbgone" # SponsorBlock
      "gbmdgpbipfallnflgajpaliibnhdgobh" # JSON Viewer
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
