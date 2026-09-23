{inputs, ...}: {
  flake-file.inputs = {
    # maki pins an old rust-overlay whose lib uses the deprecated
    # stdenv.isLinux/isDarwin; follow a current one instead.
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    maki = {
      url = "github:tontinton/maki";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.rust-overlay.follows = "rust-overlay";
    };
  };

  flake.modules.homeManager."programs/maki" = {
    pkgs,
    config,
    ...
  }: let
    # Browser control is Playwright MCP over stdio (./mcp.toml below). The
    # server ships inside playwright-core, so the browser stack we install is
    # just a node runtime plus the chromium it drives: no npm, and nothing is
    # downloaded at runtime.
    playwright = pkgs.playwright;
    playwrightBrowsers = pkgs.playwright-driver.selectBrowsers {
      withFirefox = false;
      withWebkit = false;
      withFfmpeg = false;
    };
    node = pkgs.nodejs;

    # Server settings, spelled out in playwright-core's config.d.ts: chromium
    # from the store, a throwaway in-memory profile, headless, and artifacts
    # kept out of the repos they were taken in. `capabilities` is opt-in and
    # adds to the core set (network mocking, cookies/storage, coordinate
    # tools, PDF); the rest is on by default.
    playwrightConfig = {
      browser = {
        browserName = "chromium";
        isolated = true;
        launchOptions.headless = true;
      };
      outputDir = "${config.home.homeDirectory}/.local/state/maki/browser";
      imageResponses = "allow";
      timeouts = {
        action = 10000;
        navigation = 30000;
        settle = 500;
      };
      capabilities = [
        "network"
        "storage"
        "vision"
        "pdf"
      ];
    };

    # maki's MCP client flattens every tool-result content block to text
    # (mcp/transport.rs -> CallToolResult::joined_text), so an `image` block
    # from the server arrives as an empty result and a screenshot is invisible
    # to the model. The patch carries those blocks through as vision input, the
    # same way the builtin view_image publishes a file it reads. Self-contained
    # (maki-agent only, ~90 lines), so it rides as a patch until it lands
    # upstream.
    maki = inputs.maki.packages.${pkgs.stdenv.hostPlatform.system}.default.overrideAttrs (old: {
      patches = (old.patches or []) ++ [./mcp-images.patch];
    });
  in {
    home.packages = [
      maki

      # rtk: maki's bash plugin rewrites commands through it (probes
      # `rtk --version` at runtime; on by default via agent.rtk). Optional:
      # without it on PATH maki just runs commands unrewritten.
      pkgs.rtk
    ];

    # Themes live in ./theme.nix, which merges into this same module.
    # Force-apply the stylix theme on every startup, overriding any
    # interactively-selected theme.
    home.file.".config/maki/init.lua".text = ''
      -- Managed by Nix. Extend this file with more maki.setup() options if needed.
      maki.setup({
          always_yolo = true,
          ui = {
              theme = "stylix",
          },
          plugins = {
              completion = { enabled = true },
            },
      })
      require("opencode_usage")
    '';

    # OpenCode Go usage HUD (./opencode_usage.lua). Needs fs_read for the key
    # in maki's auth dir and run for the curl workaround (maki.net.request
    # deadlocks inside the plugin executor). A plugin.toml you wrote yourself
    # defaults to granted, so this list documents intent rather than gating it.
    home.file.".config/maki/lua/opencode_usage.lua".source = ./opencode_usage.lua;
    home.file.".config/maki/plugin.toml".text = ''
      min_maki_version = "0.4.12"

      [permissions]
      fs_read = true
      run = true
    '';

    # Browser tools. `timeout` is milliseconds and covers both the startup
    # handshake and every call, so it has to clear the server's own navigation
    # timeout (30s, set in playwright-mcp.json) or maki gives up while a page is
    # still loading. The definitions are deferred behind maki's tool_search, so
    # 52 tools do not cost the whole catalogue in every request; flip
    # always_load to true to keep them in context.
    home.file.".config/maki/playwright-mcp.json".text = builtins.toJSON playwrightConfig + "\n";
    home.file.".config/maki/mcp.toml".text = ''
      # Playwright MCP: browser_navigate, browser_snapshot (accessibility tree
      # with refs), click/fill/hover/drag/upload, tabs, dialogs, network
      # mocking, cookies and storage, emulate/device, screenshots and PDF.
      [mcp.playwright]
      command = [
        "${node}/bin/node",
        "${playwright}/lib/entry/mcp.js",
        "--config",
        "${config.home.homeDirectory}/.config/maki/playwright-mcp.json",
      ]
      environment = { PLAYWRIGHT_BROWSERS_PATH = "${playwrightBrowsers}" }
      timeout = 60000
      always_load = false
    '';
  };
}
