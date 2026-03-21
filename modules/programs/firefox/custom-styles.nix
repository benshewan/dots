_: {
  flake.modules.homeManager."programs/firefox" = {pkgs, ...}: let
    # Name of firefox profile (P.S. should be "default" in regular firefox and "dev-edition-default" for firefox dev edition)
    profile = "dev-edition-default";

    ff-ultima-theme = pkgs.fetchFromGitHub {
      owner = "soulhotel";
      repo = "FF-ULTIMA";
      rev = "f99ca1cbfee282d7d12d155d86c4e85a7c87b91a";
      sha256 = "sha256-ys0hr+WMldEq+wyPNJ584US7JKoaSwTcHaS5Dk7u/DI=";
    };

    firefox-second-sidebar = pkgs.fetchFromGitHub {
      owner = "aminought";
      repo = "firefox-second-sidebar";
      rev = "95d4f2870daa02b0a209c5583531dbf3a5ffd346";
      sha256 = "sha256-aJs74EqAVMJBPS6ox2V7S9Vp47PoHlGbBuF5DBWqwiI=";
    };
  in {
    home.file.".config/mozilla/firefox/${profile}/chrome" = {
      recursive = true;
      source = ff-ultima-theme;
    };
    # home.file.".config/mozilla/firefox/${profile}/chrome/JS" = {
    #   recursive = true;
    #   source = "${firefox-second-sidebar}/src";
    # };
  };
}
