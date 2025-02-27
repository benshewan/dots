{
  # Force extensions to be defined here
  # "*" = {
  #   blocked_install_message = "All extensions must be declared in you home-manager config";
  #   install_sources = ["https://github.com/benshewan/dots/*"];
  #   installation_mode = "blocked";
  #   allowed_types = ["extension"];
  # };

  # Ad Blocking
  # ----------------------------------------------------------------------------------

  # Ad Blocker
  "uBlock0@raymondhill.net" = {
    installation_mode = "normal_installed";
    install_url = "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi";
  };

  # Blocks Sponsor segments on Youtube videos
  "sponsorBlocker@ajay.app" = {
    installation_mode = "normal_installed";
    install_url = "https://addons.mozilla.org/firefox/downloads/latest/sponsorblock/latest.xpi";
  };

  # Bypass Website Paywalls
  "magnolia@12.34" = {
    installation_mode = "normal_installed";
    install_url = "https://gitlab.com/magnolia1234/bpc-uploads/-/raw/master/bypass_paywalls_clean-latest.xpi";
  };

  # Piracy
  # ----------------------------------------------------------------------------------

  # Torrent Control
  "{e6e36c9a-8323-446c-b720-a176017e38ff}" = {
    installation_mode = "normal_installed";
    default_area = "menupanel";
    install_url = "https://addons.mozilla.org/firefox/downloads/latest/torrent-control/latest.xpi";
  };

  # NZB Downloader
  "{96586e48-b9a2-45dd-b1a1-54fa85a97c91}" = {
    installation_mode = "normal_installed";
    install_url = "https://addons.mozilla.org/firefox/downloads/latest/nzb-unity/latest.xpi";
  };

  # Desktop Integration
  # ----------------------------------------------------------------------------------

  # Integration with KDE / Hyprland / GNOME
  # "gsconnect@andyholmes.github.io" = lib.optionalAttrs (lib.elem pkgs.gnomeExtensions.gsconnect config.home.packages) {
  #   installation_mode = "normal_installed";
  #   install_url = "https://addons.mozilla.org/firefox/downloads/latest/gsconnect/latest.xpi";
  # };

  "plasma-browser-integration@kde.org" = {
    installation_mode = "normal_installed";
    install_url = "https://addons.mozilla.org/firefox/downloads/latest/plasma-integration/latest.xpi";
  };

  # Gnome Shell Integration
  # "chrome-gnome-shell@gnome.org" = lib.optionalAttrs (lib.elem pkgs.gnomeExtensions.gsconnect config.home.packages) {
  #   installation_mode = "normal_installed";
  #   install_url = "https://addons.mozilla.org/firefox/downloads/latest/gnome-shell-integration/latest.xpi";
  # };

  # Tab Management
  # ----------------------------------------------------------------------------------

  # Sidebery Tabs
  "{3c078156-979c-498b-8990-85f7987dd929}" = {
    installation_mode = "normal_installed";
    # default_area = "navbar";
    install_url = "https://addons.mozilla.org/firefox/downloads/latest/sidebery/latest.xpi";
  };

  # New Tab Home Page
  "extension@tabliss.io" = {
    installation_mode = "normal_installed";
    install_url = "https://addons.mozilla.org/firefox/downloads/latest/tabliss/latest.xpi";
  };

  # Multi-Account Containers
  "@testpilot-containers" = {
    installation_mode = "normal_installed";
    install_url = "https://addons.mozilla.org/firefox/downloads/latest/multi-account-containers/latest.xpi";
  };

  "{c607c8df-14a7-4f28-894f-29e8722976af}" = {
    installation_mode = "normal_installed";
    install_url = "https://addons.mozilla.org/firefox/downloads/latest/temporary-containers/latest.xpi";
  };

  # Tab Sessions
  "Tab-Session-Manager@sienori" = {
    installation_mode = "normal_installed";
    install_url = "https://addons.mozilla.org/firefox/downloads/latest/tab-session-manager/latest.xpi";
  };

  # Website Specific Customizations
  # ----------------------------------------------------------------------------------

  # Youtube customization
  "enhancerforyoutube@maximerf.addons.mozilla.org" = {
    installation_mode = "normal_installed";
    install_url = "https://addons.mozilla.org/firefox/downloads/latest/enhancer-for-youtube/latest.xpi";
  };

  # View Xpi Id's in Firefox Extension Store
  "queryamoid@kaply.com" = {
    installation_mode = "normal_installed";
    install_url = "https://github.com/mkaply/queryamoid/releases/download/v0.1/query_amo_addon_id-0.1-fx.xpi";
  };

  # Reddit
  "jid1-xUfzOsOFlzSOXg@jetpack" = {
    installation_mode = "normal_installed";
    install_url = "https://addons.mozilla.org/firefox/downloads/latest/reddit-enhancement-suite/latest.xpi";
  };

  # Twitch
  "twitch5@coolcmd" = {
    installation_mode = "normal_installed";
    install_url = "https://addons.mozilla.org/firefox/downloads/latest/twitch_5/latest.xpi";
  };
  # Development
  # ----------------------------------------------------------------------------------

  # React Integration
  "@react-devtools" = {
    installation_mode = "normal_installed";
    install_url = "https://addons.mozilla.org/firefox/downloads/latest/react-devtools/latest.xpi";
  };

  # Redux Integration
  "extension@redux.devtools" = {
    installation_mode = "normal_installed";
    install_url = "https://addons.mozilla.org/firefox/downloads/latest/reduxdevtools/latest.xpi";
  };

  # Other
  # ----------------------------------------------------------------------------------

  # Password Manager
  "{446900e4-71c2-419f-a6a7-df9c091e268b}" = {
    installation_mode = "normal_installed";
    default_area = "navbar";
    install_url = "https://addons.mozilla.org/firefox/downloads/latest/bitwarden-password-manager/latest.xpi";
  };

  # View the web in dark mode
  "addon@darkreader.org" = {
    installation_mode = "normal_installed";
    install_url = "https://addons.mozilla.org/firefox/downloads/latest/darkreader/latest.xpi";
  };

  # Canadian English
  "en-CA@dictionaries.addons.mozilla.org" = {
    installation_mode = "normal_installed";
    install_url = "https://addons.mozilla.org/firefox/downloads/latest/canadian-english-dictionary/latest.xpi";
  };

  "langpack-en-CA@firefox.mozilla.org" = {
    installation_mode = "normal_installed";
    install_url = "https://addons.mozilla.org/firefox/downloads/latest/english-ca-language-pack/latest.xpi";
  };
}
