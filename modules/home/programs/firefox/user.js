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
user_pref("privacy.resistFingerprinting.block_mozAddonManager", true) // also required to get extensions working on the addon store
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


//For https://github.com/aminought/firefox-second-sidebar
user_pref("dom.allow_scripts_to_close_windows", true);


// Smooth fox
// ---------------------------------------------------------------------------------------------------------------------------------------------------

user_pref("apz.overscroll.enabled", true); // DEFAULT NON-LINUX
user_pref("general.smoothScroll", true); // DEFAULT
user_pref("general.smoothScroll.msdPhysics.enabled", true);
user_pref("mousewheel.default.delta_multiplier_y", 300); // 250-400; adjust this number to your liking

// ---------------------------------------------------------------------------------------------------------------------------------------------------

/*///////////////////////////////////////////////////////////////////////////////////////\

┏┓┏┓  ┳┳┓ ┏┳┓┳┳┳┓┏┓
┣ ┣   ┃┃┃  ┃ ┃┃┃┃┣┫
┻ ┻   ┗┛┗┛ ┻ ┻┛ ┗┛┗

FF Ultima:         https://github.com/soulhotel/FF-ULTIMA
Wiki:              https://github.com/soulhotel/FF-ULTIMA/wiki/Settings
Latest Version:    https://github.com/soulhotel/FF-ULTIMA/releases/latest
License:           https://github.com/soulhotel/FF-ULTIMA/blob/main/LICENSE MPL 2.0

\////////////////////////////////////////////////////////////////////////////////////////*/

/* color schemes */
user_pref("user.theme.0.default", false);
user_pref("user.theme.transparent", false);
user_pref("user.theme.catppuccin", false);
user_pref("user.theme.catppuccin-frappe", false);
user_pref("user.theme.catppuccin-mocha", false);
user_pref("user.theme.gruvbox", true);
user_pref("user.theme.kanagawa-wave", false);
user_pref("user.theme.midnight", false);
user_pref("user.theme.midnight.animated.background", false);
user_pref("user.theme.scarlet", false);
user_pref("user.theme.fluent", false);
user_pref("user.theme.fluent.thinkpad", false);

/* nav bar */
user_pref("ultima.navbar.autohide", false);
user_pref("ultima.navbar.float", true);
user_pref("ultima.navbar.float.fullsize", false);
user_pref("ultima.navbar.hide.buttons", false);
user_pref("ultima.navbar.bookmarks.autohide", true);
user_pref("ultima.navbar.bookmarks.compact", false);
user_pref("ultima.navbar.bookmarks.position", "center");
user_pref("ultima.navbar.bookmarks.scrollable", true);
user_pref("ultima.navbar.bookmarks.float", false);
user_pref("ultima.navbar.bookmarks.hide.icons", false);
user_pref("ultima.navbar.windowcontrols.carl", false);
user_pref("ultima.navbar.windowcontrols.trafficlights", false);
user_pref("ultima.navbar.windowcontrols.whiteout", false);
user_pref("ultima.navbar.windowcontrols.fluent", false);
user_pref("ultima.navbar.theme.extensionspanel", true);
user_pref("ultima.disable.windowcontrols.button", true);
user_pref("ultima.navbar.update.ready.label", false);
user_pref("ultima.navbar.text.for.icons", false);
user_pref("ultima.navbar.bookmarks.tab.indicator", false);
user_pref("ultima.navbar.bookmarks.focus.blur", false);

/* url bar */
user_pref("ultima.urlbar.animate.open", true);
user_pref("ultima.urlbar.animate.options", false);
user_pref("ultima.urlbar.hide.searchsuggestions", false);
user_pref("ultima.urlbar.centered", true);
user_pref("ultima.urlbar.hide.buttons", true);
user_pref("ultima.urlbar.transparent", false);
user_pref("ultima.urlbar.float", false);
user_pref("ultima.urlbar.drags.window", false);
user_pref("ultima.urlbar.scrollable", false);
user_pref("ultima.urlbar.focus.blur", true);
user_pref("ultima.urlbar.focus.blur.all", false);
user_pref("ultima.urlbar.focus.text.aligns.left", false);
user_pref("ultima.urlbar.hide.buttons.in.edge", false);
user_pref("ultima.urlbar.hide.trackingprotection.icon", false);

/* sidebar */
user_pref("ultima.sidebar.seperator", false);
user_pref("ultima.sidebar.hide.header", true);
user_pref("ultima.sidebar.revamped.hide.when.horizontal", true);

/* sidebery */
user_pref("ultima.sidebery.autohide", true);
user_pref("ultima.sidebery.expandon.inactive.windows", false);
user_pref("user.theme.xtension.sidebery", true);

/* findbar */
user_pref("ultima.findbar.position.top", true);
user_pref("ultima.findbar.disable.background.image", false);

/* tabs related settings */
user_pref("ultima.spacing.compact.tabs", true);
user_pref("ultima.tabs.disable.update.dot", true);
user_pref("ultima.tabs.belowURLbar", true);
user_pref("ultima.tabs.hide.splitter", false);
user_pref("ultima.tabs.not.a.progress.bar", true);
user_pref("ultima.tabs.newtabbutton.ontop.1", false);
user_pref("ultima.tabs.newtabbutton.ontop.2", false);
user_pref("ultima.tabs.multiline.labels", false);
user_pref("ultima.tabs.closetabbutton.on.icon", false);
user_pref("ultima.tabs.pinned.always.visible", false);
user_pref("ultima.tabs.pinned.transparent.background", false);
user_pref("ultima.tabs.tabbar.autohide", false);
user_pref("ultima.tabs.tabbar.disabled", true);
user_pref("ultima.tabs.tabbar.hide.buttonstrip", false);
user_pref("ultima.tabs.tabgroups.label.1", false);
user_pref("ultima.tabs.tabgroups.label.2", false);
user_pref("ultima.tabs.tabgroups.label.3", true);
user_pref("ultima.tabs.tabgroups.label.tthornton", false);
user_pref("ultima.tabs.tabgroups.background.1", false);
user_pref("ultima.tabs.tabgroups.background.2", true);
user_pref("ultima.tabs.tabgroups.background.3", false);
user_pref("ultima.tabs.disable.scrollbar", false);
user_pref("ultima.tabs.horizontal.under.navbar", true);
user_pref("ultima.tabs.horizontal.fullwidth", false);
user_pref("ultima.tabs.focus.blur", false);
user_pref("ultima.tabs.tabCounter", false);
user_pref("ultima.tabs.splitview.tab.seperator", false);
user_pref("ultima.tabs.splitview.content.outline", false);
user_pref("ultima.tabs.splitview.focus.opacity", false);
user_pref("ultima.tabs.splitview.focus.shrink", false);
user_pref("ultima.tabs.splitview.gradient.background", false);

/* vertical tabs defaults */
user_pref("sidebar.revamp", true);
user_pref("sidebar.expandOnHover", true);
user_pref("sidebar.revamp.defaultLauncherVisible", true);
user_pref("sidebar.expandOnHoverMessage.dismissed", false);
user_pref("sidebar.visibility", "expand-on-hover");
user_pref("sidebar.revamp.round-content-area", false); /*handled by theme*/
user_pref("sidebar.animation.expand-on-hover.duration-ms", 140);
user_pref("browser.tabs.tabMinWidth", 0); /*dont touch*/

/* context menus */
user_pref("ultima.spacing.compact.menus", true);
user_pref("ultima.spacing.compact.contextmenu", true);
user_pref("ultima.spacing.relaxed.contextmenu", false);
user_pref("ultima.contextmenu.no.icons", false);
user_pref("ultima.contextmenu.no.navigation.icons", false);
user_pref("ultima.contextmenu.reduce.options", false);

/* alternate styles */
user_pref("ultima.spacing.compact", false);
user_pref("ultima.spacing.relaxed", false); /*wip*/
user_pref("ultima.tabs.tabContainer.1", false);
user_pref("ultima.tabs.tabContainer.2", false);
user_pref("ultima.tabs.tabContainer.3", true);
user_pref("user.theme.xtension.newtab.rounded", false); /*new tab page*/
user_pref("user.theme.xtension.newtab.compact", true);
user_pref("ultima.xstyle.private", true); /*private browser home page*/
user_pref("ultima.spacing.compact.addonmanager", true); /*add on manager*/
user_pref("ultima.privatebrowsing.gradient.border", false);

/* extra theming */
user_pref("ultima.theme.icons", true);
user_pref("user.theme.xtension.ublock", true);
user_pref("user.theme.xtension.YT", false);
user_pref("user.theme.xtension.reddit", false);
user_pref("ultima.scrollbar.thin", false);
user_pref("user.theme.xtension.swap.addon.colors", true);
user_pref("user.theme.xtras.tab.outline.color", "none");

/* override wallpapers */
user_pref("user.theme.wallpaper.catppuccin", false);
user_pref("user.theme.wallpaper.catppuccin-mocha", false);
user_pref("user.theme.wallpaper.catppuccin-frappe", false);
user_pref("user.theme.wallpaper.dusky", false);
user_pref("user.theme.wallpaper.fullmoon", false);
user_pref("user.theme.wallpaper.green", false);
user_pref("user.theme.wallpaper.gruvbox", false);
user_pref("user.theme.wallpaper.gruvbox.flowers", false);
user_pref("user.theme.wallpaper.gruvbox.light", false);
user_pref("user.theme.wallpaper.kanagawa-wave", false);
user_pref("user.theme.wallpaper.midnight", false);
user_pref("user.theme.wallpaper.midnight2", false);
user_pref("user.theme.wallpaper.fluent.dark", false);
user_pref("user.theme.wallpaper.fluent.light", false);
user_pref("browser.newtabpage.activity-stream.newtabWallpapers.v2.enabled", true);
user_pref("browser.newtabpage.activity-stream.newtabWallpapers.customWallpaper.enabled", true);
user_pref("browser.newtabpage.activity-stream.improvesearch.handoffToAwesomebar", false);

/* extra configs */
user_pref("ultima.enable.nightly.config", false);
user_pref("ultima.enable.js.config", false);
user_pref("widget.windows.mica", false);
user_pref("widget.windows.mica.extra", false);
user_pref("widget.windows.mica.popups", 2);
user_pref("widget.windows.mica.toplevel-backdrop", 2);
user_pref("widget.macos.titlebar-blend-mode.behind-window", false);
user_pref("browser.tabs.allow_transparent_browser", false); /* user must toggle */

/* extra required */
user_pref("ultima.xstyle.highlight.aboutconfig", true);
user_pref("browser.aboutConfig.showWarning", false);
user_pref("toolkit.legacyUserProfileCustomizations.stylesheets", true);
user_pref("devtools.debugger.remote-enabled", true);
user_pref("devtools.chrome.enabled", true);
user_pref("devtools.debugger.prompt-connection", false);
user_pref("svg.context-properties.content.enabled", true);
user_pref("layout.css.has-selector.enabled", true);
user_pref("widget.gtk.ignore-bogus-leave-notify", 1);
user_pref("widget.gtk.rounded-bottom-corners.enabled", true);
user_pref("widget.gtk.native-context-menus", false);

/* extra recommended */
user_pref("browser.tabs.groups.enabled", true);
user_pref("browser.tabs.splitView.enabled", true);
user_pref("browser.tabs.hoverPreview.enabled", true);
user_pref("browser.tabs.groups.hoverPreview.enabled", true);
user_pref("browser.newtabpage.activity-stream.feeds.section.topstories", false);
user_pref("browser.newtabpage.activity-stream.newtabShortcuts.refresh", false);

/* extra accessibility */
user_pref("findbar.highlightAll", true);
user_pref("browser.tabs.insertAfterCurrent", true);
user_pref("browser.search.context.loadInBackground", true);
user_pref("browser.bookmarks.openInTabClosesMenu", false);
user_pref("full-screen-api.transition-duration.enter", "0 0");
user_pref("full-screen-api.transition-duration.leave", "0 0");
user_pref("full-screen-api.warning.timeout", 0);

/* extra privacy */
user_pref("browser.send_pings", false);
user_pref("extensions.pocket.enabled", false);