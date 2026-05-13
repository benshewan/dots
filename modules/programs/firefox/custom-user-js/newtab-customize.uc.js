// ==UserScript==
// @name           Restore browser.newtab.url in about:config (Force Empty URL Bar)
// @author         TheRealPSV (Updated for fx-autoconfig & Modern Firefox)
// @include        main
// @shutdown       UC.NewTabAboutConfig.destroy();
// @onlyonce
// ==/UserScript==

(function () {
  const { AboutNewTab } = ChromeUtils.importESModule(
    "resource:///modules/AboutNewTab.sys.mjs",
  );

  window.UC = window.UC || {};

  UC.NewTabAboutConfig = {
    NEW_TAB_CONFIG_PATH: "browser.newtab.url",

    init: function () {
      try {
        this.newTabURL = Services.prefs.getStringPref(this.NEW_TAB_CONFIG_PATH);
      } catch (e) {
        this.newTabURL = "about:blank";
        Services.prefs.setStringPref(this.NEW_TAB_CONFIG_PATH, this.newTabURL);
      }

      this.applyUrl(this.newTabURL);

      this.prefObserver = {
        observe: (subject, topic, data) => {
          if (data === this.NEW_TAB_CONFIG_PATH) {
            try {
              this.applyUrl(
                Services.prefs.getStringPref(this.NEW_TAB_CONFIG_PATH),
              );
            } catch (e) {}
          }
        },
      };
      Services.prefs.addObserver(this.NEW_TAB_CONFIG_PATH, this.prefObserver);

      // FORCEFULLY clear the URL bar when our custom new tab is loaded
      this.progressListener = {
        onLocationChange: (
          aBrowser,
          aWebProgress,
          aRequest,
          aLocation,
          aFlags,
        ) => {
          // Check if the currently loading URL is our custom new tab
          if (aLocation && aLocation.spec === this.newTabURL) {
            // requestAnimationFrame ensures we clear it AFTER Firefox tries to update the UI
            window.requestAnimationFrame(() => {
              if (
                window.gBrowser &&
                window.gBrowser.selectedBrowser === aBrowser
              ) {
                window.gURLBar.value = "";
                window.gBrowser.userTypedValue = null;
              }
            });
          }
        },
      };

      // Attach the listener to the browser window
      if (window.gBrowser) {
        window.gBrowser.addProgressListener(this.progressListener);
      }
    },

    applyUrl: function (url) {
      // 1. Normalize the URL (e.g., automatically add trailing slashes to domains)
      // This prevents matching failures when the page loads.
      try {
        url = Services.io.newURI(url).spec;
      } catch (e) {
        // If it throws an error (e.g., invalid URI format), just use the raw string
      }

      // 2. Clean up the old URL from gInitialPages
      if (this.newTabURL && typeof window.gInitialPages !== "undefined") {
        let idx = window.gInitialPages.indexOf(this.newTabURL);
        if (idx !== -1) {
          window.gInitialPages.splice(idx, 1);
        }
      }

      // 3. Apply the new URL globally
      this.newTabURL = url;
      AboutNewTab.newTabURL = this.newTabURL;

      // 4. Add the normalized URL back into gInitialPages
      if (
        typeof window.gInitialPages !== "undefined" &&
        !window.gInitialPages.includes(this.newTabURL)
      ) {
        window.gInitialPages.push(this.newTabURL);
      }
    },

    destroy: function () {
      if (this.prefObserver) {
        Services.prefs.removeObserver(
          this.NEW_TAB_CONFIG_PATH,
          this.prefObserver,
        );
      }

      // Detach the progress listener on script shutdown
      if (this.progressListener && window.gBrowser) {
        window.gBrowser.removeProgressListener(this.progressListener);
      }

      if (this.newTabURL && typeof window.gInitialPages !== "undefined") {
        let idx = window.gInitialPages.indexOf(this.newTabURL);
        if (idx !== -1) {
          window.gInitialPages.splice(idx, 1);
        }
      }
    },
  };

  UC.NewTabAboutConfig.init();
})();
