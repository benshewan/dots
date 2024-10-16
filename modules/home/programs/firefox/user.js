// Overrides
user_pref("browser.startup.page", 3); // browser should restore previous session
//fix for hover on drag (fixes sideberry tab drag, does not work on hyprland) https://bugzilla.mozilla.org/show_bug.cgi?id=1818517
user_pref("widget.gtk.ignore-bogus-leave-notify", 1);
user_pref("widget.use-xdg-desktop-portal", true); // tell firefox to use my XDG Portal
user_pref("browser.tabs.firefox-view", false); // disable Firefox View
user_pref("browser.tabs.firefox-view-next", false); // disable firefox view
user_pref("browser.download.useDownloadDir", true); // one-click downloads
user_pref("accessibility.force_disabled", 1); // disable Accessibility features
user_pref("browser.toolbars.bookmarks.visibility", "never"); // always hide bookmark bar
user_pref("browser.urlbar.trimHttps", true); // hide https in URL bar [FF119]
user_pref(
  "media.videocontrols.picture-in-picture.display-text-tracks.size",
  "small"
); // PiP
user_pref(
  "media.videocontrols.picture-in-picture.urlbar-button.enabled",
  false
); // PiP in address bar
// user_pref("network.trr.confirmationNS", "skip"); // skip TRR confirmation request
user_pref("extensions.webextensions.restrictedDomains", ""); // remove Mozilla domains so adblocker works on pages
user_pref("browser.sessionstore.restore_pinned_tabs_on_demand", true); // force pinned tabs to not load on startup
// user_pref("browser.sessionhistory.max_total_viewers", 4); // only remember # of pages in Back-Forward cache
user_pref("media.eme.enabled", true); // enable DRM protected content
user_pref("browser.eme.ui.enabled", false); // hide DRM ui
user_pref("identity.fxaccounts.enabled", true); // enable firefox sync
user_pref("browser.tabs.firefox-view", false); // disable firefox view
user_pref("general.autoScroll", false); // disable middle click to scroll
user_pref(
  "browser.newtabpage.activity-stream.logowordmark.alwaysVisible",
  true
); // Firefox logo to always show
user_pref("pdfjs.sidebarViewOnLoad", 1); // no sidebar on pdf by default
user_pref("widget.gtk.hide-pointer-while-typing.enabled", false);
user_pref("browser.tabs.closeWindowWithLastTab", true);
user_pref("permissions.default.shortcuts", 0);
user_pref("browser.startup.homepage_override.mstone", "ignore"); // What's New page after updates; master switch
user_pref("browser.urlbar.suggest.topsites", false); // Shortcuts; disable dropdown suggestions with empty query
user_pref("devtools.accessibility.enabled", false); // removes un-needed "Inspect Accessibility Properties" on right-click
user_pref("media.peerconnection.ice.default_address_only", false);

// /** for 12 GB+ RAM ***/
// user_pref("browser.cache.disk.enable", false);
// user_pref("browser.cache.memory.capacity", 256000); // default= -1 (32768)
// user_pref("browser.cache.memory.max_entry_size", 10240); // default=5120 (5 MB)
// user_pref("media.memory_cache_max_size", 131072); // default=8192; AF=65536
// user_pref("media.memory_caches_combined_limit_kb", 1048576); // default=524288
// user_pref("media.memory_caches_combined_limit_pc_sysmem", 10); // default=5

// Web Renderer
user_pref("gfx.webrender.all", true);
user_pref("gfx.webrender.precache-shaders", true);
user_pref("gfx.webrender.compositor", true);
user_pref("gfx.webrender.compositor.force-enabled", true);
user_pref("gfx.canvas.accelerated", true);

// Network
//[WARNING] Cannot open HTML files bigger than 4MB
// user_pref("network.buffer.cache.size", 262144);
// user_pref("network.buffer.cache.count", 128);
// user_pref("network.http.pacing.requests.min-parallelism", 10);
// user_pref("network.http.pacing.requests.burst", 14);
// user_pref("network.dnsCacheEntries", 1000);
// user_pref("network.dns.disablePrefetchFromHTTPS", false);
// user_pref("network.http.speculative-parallel-limit", 6);
// user_pref("network.fetchpriority.enabled", true);
// user_pref("network.early-hints.enabled", true);
// user_pref("network.early-hints.preconnect.enabled", true);
// user_pref("network.early-hints.preconnect.max_connections", 10); // DEFAULT
// user_pref("network.predictor.enabled", true);
// user_pref("network.predictor.enable-prefetch", true);
// user_pref("network.predictor.enable-hover-on-ssl", true);
// user_pref("network.predictor.max-resources-per-entry", 250); // default=100
// user_pref("network.predictor.max-uri-length", 1000); // default=500

// Memory
// Set this to some high value, e.g. 2/3 of total memory available in your system:
// 4GB=2640, 8GB=5280, 16GB=10560, 32GB=21120, 64GB=42240
user_pref("browser.low_commit_space_threshold_mb", 42240);
user_pref("browser.low_commit_space_threshold_percent", 33); // default=5; LINUX
user_pref("browser.tabs.min_inactive_duration_before_unload", 300000); // 5min; default=600000

// Firefox Gnome Theme Tweaks
user_pref("gnomeTheme.extensions.tabCenterReborn", true);
user_pref("svg.context-properties.content.enabled", true);
user_pref("toolkit.legacyUserProfileCustomizations.stylesheets", true);

// Legacy Extension
user_pref("xpinstall.signatures.required", false);
user_pref("extensions.experiments.enabled", true);

// disable ALT behaviour
user_pref("ui.key.menuAccessKeyFocuses", false);

/****************************************************************************************
 * OPTION: NATURAL SMOOTH SCROLLING V3 [MODIFIED]                                      *
 ****************************************************************************************/
// credit: https://github.com/AveYo/fox/blob/cf56d1194f4e5958169f9cf335cd175daa48d349/Natural%20Smooth%20Scrolling%20for%20user.js
// recommended for 120hz+ displays
// largely matches Chrome flags: Windows Scrolling Personality and Smooth Scrolling
user_pref("apz.overscroll.enabled", true); // DEFAULT NON-LINUX
user_pref("general.smoothScroll", true); // DEFAULT
user_pref("general.smoothScroll.msdPhysics.continuousMotionMaxDeltaMS", 12);
user_pref("general.smoothScroll.msdPhysics.enabled", true);
user_pref("general.smoothScroll.msdPhysics.motionBeginSpringConstant", 600);
user_pref("general.smoothScroll.msdPhysics.regularSpringConstant", 650);
user_pref("general.smoothScroll.msdPhysics.slowdownMinDeltaMS", 25);
user_pref("general.smoothScroll.msdPhysics.slowdownMinDeltaRatio", 2.0);
user_pref("general.smoothScroll.msdPhysics.slowdownSpringConstant", 250);
user_pref("general.smoothScroll.currentVelocityWeighting", 1.0);
user_pref("general.smoothScroll.stopDecelerationWeighting", 1.0);
user_pref("mousewheel.default.delta_multiplier_y", 200); // 250-400; adjust this number to your liking
