// ==UserScript==
// @name           Backtrack (inherit parent tab history)
// @description    When a tab is opened from another tab (link, middle-click, ctrl-click, window.open),
//                 the new tab inherits the parent tab's back-history so the Back button walks through
//                 the parent's previous pages. Mirrors the old "Backtrack" Firefox extension.
// @author         ben
// @include        main
// @onlyonce
// @shutdown       UC.Backtrack.destroy();
// ==/UserScript==

(function () {
  const { SessionStore } = ChromeUtils.importESModule(
    "resource:///modules/sessionstore/SessionStore.sys.mjs"
  );
  const { TabStateFlusher } = ChromeUtils.importESModule(
    "resource:///modules/sessionstore/TabStateFlusher.sys.mjs"
  );

  window.UC = window.UC || {};

  UC.Backtrack = {
    // tab -> array of parent history entries to prepend
    pending: new WeakMap(),
    // tab -> true while we're applying setTabState (suppress reentry)
    applying: new WeakMap(),

    init() {
      this.onTabOpen = this.onTabOpen.bind(this);

      this.progressListener = {
        QueryInterface: ChromeUtils.generateQI([
          "nsIWebProgressListener",
          "nsISupportsWeakReference",
        ]),
        onLocationChange: (aBrowser, aWebProgress, aRequest, aLocation, aFlags) => {
          if (!aLocation) return;
          if (aFlags & Ci.nsIWebProgressListener.LOCATION_CHANGE_SAME_DOCUMENT) return;
          if (!aWebProgress.isTopLevel) return;

          const tab = gBrowser.getTabForBrowser(aBrowser);
          if (!tab) return;
          if (UC.Backtrack.applying.get(tab)) return;

          const parentEntries = UC.Backtrack.pending.get(tab);
          if (!parentEntries) return;

          // Skip the synthetic about:blank that sometimes fires before the real load.
          if (aLocation.spec === "about:blank") return;

          UC.Backtrack.pending.delete(tab);
          UC.Backtrack.merge(tab, parentEntries).catch(e => Cu.reportError(e));
        },
      };

      gBrowser.tabContainer.addEventListener("TabOpen", this.onTabOpen);
      gBrowser.addTabsProgressListener(this.progressListener);
    },

    onTabOpen(e) {
      const tab = e.target;
      const opener = tab.openerTab;
      if (!opener || opener === tab || opener.closing) return;

      // Capture asynchronously: flush opener first so its latest entry (the page the
      // user is currently looking at in the parent tab) is present in the cached state.
      this.pending.set(tab, this.captureParent(opener));
    },

    async captureParent(opener) {
      const openerBrowser = opener.linkedBrowser;
      const openerURI = openerBrowser && openerBrowser.currentURI
        ? openerBrowser.currentURI.spec
        : null;

      try {
        if (openerBrowser) await TabStateFlusher.flush(openerBrowser);
      } catch (_) {}

      if (opener.closing) return null;

      let state;
      try {
        state = JSON.parse(SessionStore.getTabState(opener));
      } catch (_) {
        return null;
      }
      if (!state || !Array.isArray(state.entries) || !state.entries.length) return null;

      // SessionStore index is 1-based; clamp.
      const idx = Math.max(0, Math.min(state.entries.length, state.index || 1) - 1);
      const entries = state.entries.slice(0, idx + 1);
      if (!entries.length) return null;

      // Safety net: if the flush still missed the parent's current URL, synthesize an
      // entry for it so the new tab's Back button lands on the parent's current page.
      const last = entries[entries.length - 1];
      if (openerURI && (!last || last.url !== openerURI) && !/^about:blank$/.test(openerURI)) {
        entries.push({
          url: openerURI,
          title: opener.label || openerURI,
          triggeringPrincipal_base64: last && last.triggeringPrincipal_base64
            ? last.triggeringPrincipal_base64
            : undefined,
        });
      }

      return entries;
    },

    async merge(tab, parentEntriesOrPromise) {
      const browser = tab.linkedBrowser;
      if (!browser) return;

      const parentEntries = await parentEntriesOrPromise;
      if (!parentEntries || !parentEntries.length) return;

      // Make sure the child's first history entry is reflected in SessionStore's cache.
      try {
        await TabStateFlusher.flush(browser);
      } catch (_) {
        return;
      }
      if (!tab.isConnected || tab.closing) return;

      let childState;
      try {
        childState = JSON.parse(SessionStore.getTabState(tab));
      } catch (_) {
        return;
      }
      const childEntries = childState && Array.isArray(childState.entries) ? childState.entries : [];
      if (!childEntries.length) return;

      // Don't bother prepending if the child only has about:blank / about:newtab — leave it alone.
      const firstChildUrl = childEntries[0].url || "";
      if (
        firstChildUrl === "about:blank" ||
        firstChildUrl === "about:newtab" ||
        firstChildUrl === "about:home"
      ) {
        return;
      }

      const childIdx = Math.max(1, childState.index || 1);
      const merged = {
        ...childState,
        entries: [...parentEntries, ...childEntries],
        index: parentEntries.length + childIdx,
      };

      this.applying.set(tab, true);
      try {
        SessionStore.setTabState(tab, JSON.stringify(merged));
      } catch (e) {
        Cu.reportError(e);
      } finally {
        // Clear the suppression flag once the restore-driven load settles.
        setTimeout(() => this.applying.delete(tab), 0);
      }
    },

    destroy() {
      try {
        gBrowser.tabContainer.removeEventListener("TabOpen", this.onTabOpen);
      } catch (_) {}
      try {
        gBrowser.removeTabsProgressListener(this.progressListener);
      } catch (_) {}
      this.pending = new WeakMap();
      this.applying = new WeakMap();
    },
  };

  if (gBrowserInit && gBrowserInit.delayedStartupFinished) {
    UC.Backtrack.init();
  } else {
    const obs = (subject, topic) => {
      if (subject === window) {
        Services.obs.removeObserver(obs, "browser-delayed-startup-finished");
        UC.Backtrack.init();
      }
    };
    Services.obs.addObserver(obs, "browser-delayed-startup-finished");
  }
})();
