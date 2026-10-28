flake @ {inputs, ...}: let
  username = flake.config.flake.meta.user.username;
  # sops-nix template for EXA_API_KEY (nixos module below), rendered to tmpfs.
  exaEnvPath = "/run/secrets/rendered/maki-env";
in {
  flake-file.inputs = {
    # rust-overlay: maki pins an old copy whose lib uses the deprecated stdenv.isLinux.
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
    lib,
    config,
    ...
  }: let
    # Browser stack: playwright-core ships the MCP server; this is just node +
    # chromium from the store (steps in ./mcp.toml below; nothing at runtime).
    playwright = pkgs.playwright;
    playwrightBrowsers = pkgs.playwright-driver.selectBrowsers {
      withFirefox = false;
      withWebkit = false;
      withFfmpeg = false;
    };
    node = pkgs.nodejs;

    # GitHub MCP: PAT resolved at runtime (env, ~/.config/maki/github-mcp.token, or `gh`);
    # never baked into the store.
    githubMcpServer = pkgs.github-mcp-server;
    githubMcpWrapper = pkgs.writeShellScript "maki-github-mcp" ''
      set -eu
      token="''${GITHUB_PERSONAL_ACCESS_TOKEN:-}"
      if [ -z "$token" ]; then
        file="''${XDG_CONFIG_HOME:-$HOME/.config}/maki/github-mcp.token"
        if [ -r "$file" ]; then
          token=$(cat "$file")
        fi
      fi
      if [ -z "$token" ] && command -v gh >/dev/null 2>&1; then
        token=$(gh auth token 2>/dev/null || true)
      fi
      if [ -z "$token" ]; then
        echo "github-mcp: no token; set GITHUB_PERSONAL_ACCESS_TOKEN or write ~/.config/maki/github-mcp.token" >&2
        exit 1
      fi
      GITHUB_PERSONAL_ACCESS_TOKEN="$token"
      export GITHUB_PERSONAL_ACCESS_TOKEN
      exec ${githubMcpServer}/bin/github-mcp-server "$@"
    '';

    # Chromium from the store, in-memory profile, headless; capabilities per
    # playwright-core's config.d.ts.
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

    maki = inputs.maki.packages.${pkgs.stdenv.hostPlatform.system}.default;

    # Rendered into ~/.config/maki/init.lua by lib.generators.toLua.
    makiSetupOptions = {
      always_yolo = true;
      ui.theme = "stylix";
      agent.compaction_buffer = "10%";
      provider.default_model = "opencode-go/deepseek-v4.1-flash";
      plugins.completion.enabled = true;
    };
  in {
    home.packages = [
      maki
      pkgs.rtk
    ];

    # The only way to hand the builtin websearch its Exa key is EXA_API_KEY in
    # the env (see the nixos module below for where it is decrypted).
    home.sessionVariablesExtra = ''
      [ -r "${exaEnvPath}" ] && . "${exaEnvPath}"
    '';

    home.file.".config/maki/init.lua".text = ''
      -- Managed by Nix. Extend this file with more maki.setup() options if needed.
      maki.setup(${lib.generators.toLua {} makiSetupOptions})
      require("opencode_usage")
      require("zai_usage")
    '';

    home.file.".config/maki/AGENTS.md".source = ./INITIAL_PROMPT.md;

    # Usage HUD plugins (fs_read: key in maki's auth dir; run: curl workaround,
    # maki.net.request deadlocks in the plugin executor). usage_hint.lua owns
    # the shared status-hint slot so the line follows the selected model.
    home.file.".config/maki/lua/opencode_usage.lua".source = ./custom-plugins/opencode_usage.lua;
    home.file.".config/maki/lua/zai_usage.lua".source = ./custom-plugins/zai_usage.lua;
    home.file.".config/maki/lua/usage_hint.lua".source = ./custom-plugins/usage_hint.lua;

    home.file.".config/maki/plugin.toml".source = pkgs.writers.writeTOML "maki-plugin.toml" {
      min_maki_version = "0.4.12";
      permissions.fs_read = true;
      permissions.run = true;
    };

    # `timeout` covers startup + every call, so it clears the 30s navigation
    # timeout in playwright-mcp.json. always_load = false: deferred behind
    # tool_search instead of costing the full catalogue in every request.
    home.file.".config/maki/playwright-mcp.json".text = builtins.toJSON playwrightConfig + "\n";
    home.file.".config/maki/mcp.toml".text = ''
      # browser navigation/snapshot/click/tabs/dialogs/network/cookies/PDF.
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

      # repos/issues/PRs/users/copilot (default toolset). PAT: env, token file, or
      # `gh auth token`. Append args for "--toolsets default,actions" or "--read-only".
      [mcp.github]
      command = [
        "${githubMcpWrapper}",
        "stdio",
        "--toolsets",
        "default",
      ]
      timeout = 60000
      always_load = false

      # Reverse-engineering workbench (Ghidra bridges, decompile, xrefs, call
      # graphs). No Ghidra-side install: REA packages its own Java bridge and
      # drives Ghidra 12.1.x headless via GHIDRA_INSTALL_DIR (or PATH discovery).
      # 42+ tools → deferred behind tool_search.
      [mcp.rea]
      command = [
        "${pkgs.local.rea}/bin/rea",
        "mcp",
      ]
      environment = { GHIDRA_INSTALL_DIR = "${pkgs.ghidra}/lib/ghidra" }
      timeout = 60000
      always_load = false
    '';
  };

  # Exa API key: decrypted by the system sops-nix module at boot (see
  # modules/flake-parts/sops-nix.nix). The raw secret (default path, root) is
  # never consumed directly; the template renders the export line to tmpfs so
  # no plaintext key lands under ~.
  #
  # Rotate with `sops secrets/common.yaml` (key: `exa-api-key`; age recipient
  # from .sops.yaml). The entry must exist before the next switch.
  flake.modules.nixos."programs/maki" = {config, ...}: {
    sops.secrets."exa-api-key" = {};

    sops.templates."maki-env" = {
      owner = username;
      mode = "0400";
      content = "export EXA_API_KEY=\"${config.sops.placeholder."exa-api-key"}\"\n";
    };
  };
}
