{pkgs, ...}: let
  legacy-extensions = pkgs.fetchFromGitHub {
    owner = "xiaoxiaoflood";
    repo = "firefox-scripts";
    rev = "b013243f1916576166a02d816651c2cc6416f63e";
    sha256 = "sha256-Zp1pRMqgAM3Xh3JCkAC0hWp2Gl2phkyAwJ8KB2tA9jE=";
    sparseCheckout = [
      "extensions"
    ];
  };
in {
  # Force extensions to be defined here
  "*" = {
    blocked_install_message = "All extensions must be declared in you home-manager config";
    install_sources = ["https://github.com/benshewan/dots/*"];
    installation_mode = "blocked";
    allowed_types = ["extension"];
  };

  # Ad Blocking
  # ----------------------------------------------------------------------------------

  # Ad Blocker
  "uBlock0@raymondhill.net" = {
    installation_mode = "force_installed";
    install_url = "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi";
  };

  # Blocks Sponsor segments on Youtube videos
  "sponsorBlocker@ajay.app" = {
    installation_mode = "force_installed";
    install_url = "https://addons.mozilla.org/firefox/downloads/latest/sponsorblock/latest.xpi";
  };

  # Bypass Website Paywalls
  "magnolia@12.34" = {
    installation_mode = "force_installed";
    install_url = "https://gitlab.com/magnolia1234/bpc-uploads/-/raw/master/bypass_paywalls_clean-latest.xpi";
  };

  # Piracy
  # ----------------------------------------------------------------------------------

  # Torrent Control
  "{e6e36c9a-8323-446c-b720-a176017e38ff}" = {
    installation_mode = "force_installed";
    default_area = "menupanel";
    install_url = "https://addons.mozilla.org/firefox/downloads/latest/torrent-control/latest.xpi";
  };

  # NZB Downloader
  "{96586e48-b9a2-45dd-b1a1-54fa85a97c91}" = {
    installation_mode = "force_installed";
    install_url = "https://addons.mozilla.org/firefox/downloads/latest/nzb-unity/latest.xpi";
  };

  # Desktop Integration
  # ----------------------------------------------------------------------------------

  # Integration with KDE / Hyprland / GNOME
  # "gsconnect@andyholmes.github.io" = lib.optionalAttrs (lib.elem pkgs.gnomeExtensions.gsconnect config.home.packages) {
  #   installation_mode = "force_installed";
  #   install_url = "https://addons.mozilla.org/firefox/downloads/latest/gsconnect/latest.xpi";
  # };

  "plasma-browser-integration@kde.org" = {
    installation_mode = "force_installed";
    install_url = "https://addons.mozilla.org/firefox/downloads/latest/plasma-integration/latest.xpi";
  };

  # Gnome Shell Integration
  # "chrome-gnome-shell@gnome.org" = lib.optionalAttrs (lib.elem pkgs.gnomeExtensions.gsconnect config.home.packages) {
  #   installation_mode = "force_installed";
  #   install_url = "https://addons.mozilla.org/firefox/downloads/latest/gnome-shell-integration/latest.xpi";
  # };

  # Tab Management
  # ----------------------------------------------------------------------------------

  # Sidebery Tabs
  "{3c078156-979c-498b-8990-85f7987dd929}" = {
    installation_mode = "force_installed";
    # default_area = "navbar";
    install_url = "https://addons.mozilla.org/firefox/downloads/latest/sidebery/latest.xpi";
  };

  "extension@tabliss.io" = {
    installation_mode = "force_installed";
    install_url = "https://addons.mozilla.org/firefox/downloads/latest/tabliss/latest.xpi";
  };

  # Website Specific Customizations
  # ----------------------------------------------------------------------------------

  # Youtube customization
  # "enhancerforyoutube@maximerf.addons.mozilla.org" = {
  #   installation_mode = "force_installed";
  #   install_url = "https://addons.mozilla.org/firefox/downloads/latest/enhancer-for-youtube/latest.xpi";
  # };

  # Remove YouTube Shorts
  "{88ebde3a-4581-4c6b-8019-2a05a9e3e938}" = {
    installation_mode = "force_installed";
    install_url = "https://addons.mozilla.org/firefox/downloads/latest/hide-youtube-shorts/latest.xpi";
  };

  # View Xpi Id's in Firefox Extension Store
  "queryamoid@kaply.com" = {
    installation_mode = "force_installed";
    install_url = "https://github.com/mkaply/queryamoid/releases/download/v0.1/query_amo_addon_id-0.1-fx.xpi";
  };

  # Reddit
  "jid1-xUfzOsOFlzSOXg@jetpack" = {
    installation_mode = "force_installed";
    install_url = "https://addons.mozilla.org/firefox/downloads/latest/reddit-enhancement-suite/latest.xpi";
  };

  # Development
  # ----------------------------------------------------------------------------------

  # React Integration
  "@react-devtools" = {
    installation_mode = "force_installed";
    install_url = "https://addons.mozilla.org/firefox/downloads/latest/react-devtools/latest.xpi";
  };

  # Redux Integration
  "extension@redux.devtools" = {
    installation_mode = "force_installed";
    install_url = "https://addons.mozilla.org/firefox/downloads/latest/reduxdevtools/latest.xpi";
  };

  # Other
  # ----------------------------------------------------------------------------------

  # Password Manager
  "{446900e4-71c2-419f-a6a7-df9c091e268b}" = {
    installation_mode = "force_installed";
    default_area = "navbar";
    install_url = "https://addons.mozilla.org/firefox/downloads/latest/bitwarden-password-manager/latest.xpi";
  };

  # View the web in dark mode
  "addon@darkreader.org" = {
    installation_mode = "force_installed";
    install_url = "https://addons.mozilla.org/firefox/downloads/latest/darkreader/latest.xpi";
  };

  # Google Translate - TODO: Firefox is slowly replacing this with its own builtin translator, but doesn't yet support languages like russian or japanese
  "{036a55b4-5e72-4d05-a06c-cba2dfcc134a}" = {
    installation_mode = "force_installed";
    install_url = "https://addons.mozilla.org/firefox/downloads/latest/traduzir-paginas-web/latest.xpi";
  };

  # Legacy Extensions
  # ----------------------------------------------------------------------------------

  # Allow you to hold ctrl to click substring of url
  "advancedlocationbar@veg.by" = {
    installation_mode = "force_installed";
    install_url = "file://${./AdvancedLocationbar2_1.2.1.7.xpi}";
  };

  # New tabs inhert the history of their parent tabs
  "backtrack@byalexv.co.uk" = {
    installation_mode = "force_installed";
    install_url = "file://${legacy-extensions}/extensions/backtrack/BackTrack.xpi";
  };
  # Tab Mix Plus
  # "{dc572301-7619-498c-a57d-39143191b318}"
}
