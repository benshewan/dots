//SmoothFox
user_pref("apz.overscroll.enabled", true); // DEFAULT NON-LINUX
user_pref("general.smoothScroll", false); // DEFAULT
user_pref("general.smoothScroll.msdPhysics.continuousMotionMaxDeltaMS", 12);
user_pref("general.smoothScroll.msdPhysics.enabled", true);

// Overrides
user_pref("browser.startup.page", 3); // browser should restore previous session
//fix for hover on drag (fixes sideberry tab drag, does not work on hyprland) https://bugzilla.mozilla.org/show_bug.cgi?id=1818517
user_pref("widget.gtk.ignore-bogus-leave-notify", 1);
user_pref("widget.use-xdg-desktop-portal", true); // tell firefox to use my XDG Portal
user_pref("browser.tabs.firefox-view-next", false); // disable firefox view
user_pref("browser.download.useDownloadDir", true); // one-click downloads
user_pref("accessibility.force_disabled", 1); // disable Accessibility features
user_pref("browser.toolbars.bookmarks.visibility", "never"); // always hide bookmark bar
user_pref("browser.urlbar.trimHttps", true); // hide https in URL bar [FF119]
user_pref("media.videocontrols.picture-in-picture.display-text-tracks.size", "small"); // PiP
user_pref("media.videocontrols.picture-in-picture.urlbar-button.enabled", false); // PiP in address bar
user_pref("network.trr.confirmationNS", "skip"); // skip TRR confirmation request
user_pref("extensions.webextensions.restrictedDomains", ""); // remove Mozilla domains so adblocker works on pages
user_pref("browser.sessionstore.restore_pinned_tabs_on_demand", true);
user_pref("browser.sessionhistory.max_total_viewers", 4); // only remember # of pages in Back-Forward cache
user_pref("media.eme.enabled", true); // enable DRM protected content
user_pref("browser.eme.ui.enabled", false); // hide DRM ui
user_pref("identity.fxaccounts.enabled", true); // enable firefox sync
user_pref("browser.tabs.firefox-view", false); // disable firefox view
user_pref("general.autoScroll", false); // disable middle click to scroll
user_pref("browser.sessionstore.restore_pinned_tabs_on_demand", false); // force pinned tabs to load on startup

/** for 12 GB+ RAM ***/
user_pref("browser.cache.disk.enable", false);
user_pref("browser.cache.memory.capacity", 256000); // default= -1 (32768)
user_pref("browser.cache.memory.max_entry_size", 10240); // default=5120 (5 MB)
user_pref("media.memory_cache_max_size", 131072); // default=8192; AF=65536
user_pref("media.memory_caches_combined_limit_kb", 1048576); // default=524288
user_pref("media.memory_caches_combined_limit_pc_sysmem", 10); // default=5

/** speculative load test ***/
user_pref("network.dns.disablePrefetchFromHTTPS", false);
//user_pref("network.prefetch-next", true);
user_pref("network.predictor.enabled", true);
user_pref("network.predictor.enable-prefetch", true);
user_pref("network.predictor.enable-hover-on-ssl", true);

// Firefox Gnome Theme Tweaks
user_pref("gnomeTheme.extensions.tabCenterReborn", true);
user_pref("svg.context-properties.content.enabled", true);
user_pref("toolkit.legacyUserProfileCustomizations.stylesheets", true);