// Overrides
user_pref("browser.startup.page", 3); // browser should restore previous session
//fix for hover on drag (fixes sideberry tab drag, does not work on hyprland) https://bugzilla.mozilla.org/show_bug.cgi?id=1818517
// user_pref("widget.gtk.ignore-bogus-leave-notify", 1);
user_pref("widget.use-xdg-desktop-portal", true); // tell firefox to use my XDG Portal
user_pref("browser.aboutConfig.showWarning", false); // don't show warning in about:config
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
user_pref("extensions.webextensions.restrictedDomains", ""); // remove Mozilla domains so adblocker works on pages
user_pref("browser.sessionstore.restore_pinned_tabs_on_demand", true); // force pinned tabs to not load on startup
// user_pref("browser.sessionhistory.max_total_viewers", 4); // only remember # of pages in Back-Forward cache
user_pref("media.eme.enabled", true); // enable DRM protected content
user_pref("browser.eme.ui.enabled", false); // hide DRM ui
user_pref("identity.fxaccounts.enabled", true); // enable firefox sync
// user_pref("browser.tabs.firefox-view", false); // disable firefox view
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
user_pref("devtools.accessibility.enabled", false); // removes un-needed "Inspect Accessibility Properties" on right-click
user_pref("media.peerconnection.ice.default_address_only", false);

user_pref("browser.contentblocking.category", "strict"); // use strict content blocking mode

user_pref("browser.display.use_system_colors", true);

// Legacy Extension
user_pref("xpinstall.signatures.required", false);
user_pref("extensions.experiments.enabled", true);

// disable ALT behaviour
user_pref("ui.key.menuAccessKeyFocuses", false);

// Zen specific features
// -----------------------------------------------------------------
user_pref("zen.glance.activation-method", "alt"); // preview tab
user_pref("zen.splitView.change-on-hover", true); // split tabs focus changes with hover
user_pref("zen.tab-unloader.enabled", false); // don't unload old tabs
user_pref("zen.tabs.show-newtab-vertical", false); // don't show new tab button
user_pref("zen.tabs.vertical", true); // use vertical tabs
user_pref("zen.theme.accent-color", "#d4bbff"); // set accent colour TODO: switch to using stylix colours

user_pref("zen.urlbar.replace-newtab", true); // don't open new tab, only address bar
user_pref("browser.urlbar.suggest.topsites", true); // Shortcuts; disable dropdown suggestions with empty query; required for new tab behavior
user_pref("browser.tabs.allow_transparent_browser", false); // fixes some websites that don't explicity set a body background color
user_pref("browser.tabs.hoverPreview.enabled", true); // show tab previews on hover
