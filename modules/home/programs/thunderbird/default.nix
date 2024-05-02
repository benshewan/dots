{pkgs, ...}: {
  programs.thunderbird = {
    enable = true;
    package = pkgs.thunderbird.override {
      extraPolicies = {
        DontCheckDefaultBrowser = true;
      };
    };
    profiles = {
      default = {
        isDefault = true;
      };
    };
  };
}
