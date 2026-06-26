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

    natsumi-theme = pkgs.fetchFromGitHub {
      owner = "greeeen-dev";
      repo = "natsumi-browser";
      rev = "4d1596553ad00c4576b6c0a5be71775798de20e6";
      sha256 = "sha256-BzeUNg3aY7uHubv2ackuH01AAeiyCXnXMBNtfBdvcFY=";
    };

    firefox-second-sidebar = pkgs.fetchFromGitHub {
      owner = "aminought";
      repo = "firefox-second-sidebar";
      rev = "95d4f2870daa02b0a209c5583531dbf3a5ffd346";
      sha256 = "sha256-aJs74EqAVMJBPS6ox2V7S9Vp47PoHlGbBuF5DBWqwiI=";
    };
  in {
    home.file.".config/mozilla/firefox/${profile}/chrome/userChrome.css".source = "${ff-ultima-theme}/userChrome.css";
    home.file.".config/mozilla/firefox/${profile}/chrome/userContent.css".source = "${ff-ultima-theme}/userContent.css";
    home.file.".config/mozilla/firefox/${profile}/chrome/theme" = {
      recursive = true;
      source = "${ff-ultima-theme}/theme";
    };

    # home.file.".config/mozilla/firefox/${profile}/chrome/userChrome.css".source = "${natsumi-theme}/userChrome.css";
    # home.file.".config/mozilla/firefox/${profile}/chrome/userContent.css".source = "${natsumi-theme}/userContent.css";
    # home.file.".config/mozilla/firefox/${profile}/chrome/natsumi" = {
    #   recursive = true;
    #   source = "${natsumi-theme}/natsumi";
    # };
    # home.file.".config/mozilla/firefox/${profile}/chrome/utils/chrome.manifest".text = ''
    #   content userchromejs ./
    #   content userscripts ../natsumi/scripts/
    #   skin userstyles classic/1.0 ../CSS/
    #   content userchrome ../resources/
    #   content natsumi ../natsumi/
    #   content natsumi-icons ../natsumi/icons/
    # '';

    # Firefox sidebar
    # home.file.".config/mozilla/firefox/${profile}/chrome/JS" = {
    #   recursive = true;
    #   source = "${firefox-second-sidebar}/src";
    # };
  };
}
