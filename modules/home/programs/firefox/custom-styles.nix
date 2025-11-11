{
  pkgs,
  config,
  lib,
  ...
}: let
  cfg = config.night-sky.programs.firefox;

  # Name of firefox profile (P.S. should be "default" in regular firefox and "dev-edition-default" for firefox dev edition)
  profile = "dev-edition-default";

  ff-ultima-theme = pkgs.fetchFromGitHub {
    owner = "soulhotel";
    repo = "FF-ULTIMA";
    rev = "dba0da142d7501daa9e3f7878c06ca24d194b4df";
    sha256 = "sha256-yAxqGuS4R591KwuzU+GmWgiKpVoxuS/1qoEaf6dbCl0=";
  };

  firefox-second-sidebar = pkgs.fetchFromGitHub {
    owner = "aminought";
    repo = "firefox-second-sidebar";
    rev = "95d4f2870daa02b0a209c5583531dbf3a5ffd346";
    sha256 = "sha256-aJs74EqAVMJBPS6ox2V7S9Vp47PoHlGbBuF5DBWqwiI=";
  };
in {
  config = lib.mkIf cfg.enable {
    home.file.".mozilla/firefox/${profile}/chrome" = {
      recursive = true;
      source = ff-ultima-theme;
    };

    home.file.".mozilla/firefox/${profile}/chrome/JS" = {
      recursive = true;
      source = "${firefox-second-sidebar}/src";
    };
  };
}
