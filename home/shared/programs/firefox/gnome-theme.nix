{
  pkgs,
  config,
  ...
}: let
  colors = config.lib.stylix.colors;
in {
  dark = pkgs.writeText "dark.css" ''
    @namespace xul url("http://www.mozilla.org/keymaster/gatekeeper/there.is.only.xul");
    @media (prefers-color-scheme: dark) {
    	:root {
    		/* Accent */
    		--gnome-accent-bg: var(--gnome-palette-blue-3);
    		--gnome-accent: #${colors.base0D};

    		--gnome-toolbar-star-button: var(--gnome-palette-yellow-1);

    		/* Window */
    		--gnome-window-background: #${colors.base00};
    		--gnome-window-color: #${colors.base05};
    		--gnome-view-background: #1e1e1e;

    		/* Card */
    		--gnome-card-background: rgba(255, 255, 255, 0.08);
    		--gnome-card-shade-color: color-mix(in srgb, black 36%, transparent);

    		/* Menu */
    		--gnome-menu-background: #${colors.base02};

    		/* Header bar */
    		--gnome-headerbar-background: #${colors.base01};
    		--gnome-headerbar-shade-color: color-mix(in srgb, black 36%, transparent);

    		/* Toolbars */
    		--gnome-toolbar-icon-fill: #${colors.base05};

    		/* Tabs */
    		--gnome-tabbar-tab-hover-background: #3f3f3f; /* Hardcoded color */
    		--gnome-tabbar-tab-active-background: #444444; /* Hardcoded color */
    		--gnome-tabbar-tab-active-background-contrast: #4F4F4F; /* Hardcoded color */
    		--gnome-tabbar-tab-active-hover-background: #4b4b4b; /* Hardcoded color */

    		--gnome-tabbar-identity-color-green: var(--gnome-palette-green-1);
    		--gnome-tabbar-identity-color-yellow: var(--gnome-palette-yellow-2);
    		--gnome-tabbar-identity-color-orange: var(--gnome-palette-orange-3);
    		--gnome-tabbar-identity-color-red: var(--gnome-palette-red-1);
    		--gnome-tabbar-identity-color-purple: var(--gnome-palette-purple-1);

    		/* Text color for Firefox Logo in new private tab */
    		--gnome-private-wordmark: #FBFBFE;
    		/* New private tab background */
    		--gnome-private-in-content-page-background: #242424;
    		/* Private browsing info box */
    		--gnome-private-text-primary-color: #FBFBFE;
    	}

    	/* Backdrop colors */
    	:root:-moz-window-inactive {
    		--gnome-tabbar-tab-hover-background: #2c2c2c; /* Hardcoded color */
    		--gnome-tabbar-tab-active-background: #2e2e2e; /* Hardcoded color */
    	}

    	/* Private colors */
    	:root[privatebrowsingmode="temporary"] {
    		--gnome-accent-fg: #78aeed;
    		/* Headerbar */
    		--gnome-headerbar-background: #252F49 !important;
    		/* Tabs */
    		--gnome-tabbar-tab-hover-background: #343e56; /* Hardcoded color */
    		--gnome-tabbar-tab-active-background: #343e56; /* Hardcoded color */
    		--gnome-tabbar-tab-active-background-contrast: #495675; /* Hardcoded color */
    		--gnome-tabbar-tab-active-hover-background: #414a61; /* Hardcoded color */
    	}

    	/* Private and backdrop colors */
    	:root[privatebrowsingmode="temporary"]:-moz-window-inactive {
    		--gnome-headerbar-background: #252F49 !important;
    		--gnome-tabbar-tab-hover-background: #242c3f; /* Hardcoded color */
    		--gnome-tabbar-tab-active-background: #272e41; /* Hardcoded color */
    	}
    }
  '';
}
