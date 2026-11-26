{...} @ flake: let
  username = flake.config.flake.meta.user.username;
in {
  flake.modules.homeManager."programs/maki" = {
    pkgs,
    config,
    ...
  }: let
    # playwright-core ships the MCP server; node + chromium come from the store.
    playwright = pkgs.playwright;
    playwrightBrowsers = pkgs.playwright-driver.selectBrowsers {
      withFirefox = false;
      withWebkit = false;
      withFfmpeg = false;
    };
    node = pkgs.nodejs;

    githubMcpServer = pkgs.github-mcp-server;
    githubMcpWrapper = pkgs.writeShellScript "maki-github-mcp" ''
      set -eu
      pat_file="/run/secrets/github-pat"
      if [ ! -r "$pat_file" ]; then
        echo "github-mcp: $pat_file missing; add github-pat to secrets/common.yaml" >&2
        exit 1
      fi
      GITHUB_PERSONAL_ACCESS_TOKEN="$(cat "$pat_file")"
      export GITHUB_PERSONAL_ACCESS_TOKEN
      exec ${githubMcpServer}/bin/github-mcp-server "$@"
    '';

    # In-memory profile, headless; shape per playwright-core's config.d.ts.
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

    # `timeout` covers startup + every call (clears the 30s navigation
    # timeout); always_load = false defers servers behind tool_search.
    mcpServers = {
      # browser navigation/snapshot/click/tabs/dialogs/network/cookies/PDF.
      mcp.playwright = {
        command = [
          "${node}/bin/node"
          "${playwright}/lib/entry/mcp.js"
          "--config"
          "${config.home.homeDirectory}/.config/maki/playwright-mcp.json"
        ];
        environment.PLAYWRIGHT_BROWSERS_PATH = "${playwrightBrowsers}";
        timeout = 60000;
        always_load = false;
      };

      # repos/issues/PRs/users/copilot; append "--toolsets default,actions"
      # or "--read-only" for more.
      mcp.github = {
        command = [
          "${githubMcpWrapper}"
          "stdio"
          "--toolsets"
          "default"
        ];
        timeout = 60000;
        always_load = false;
      };
    };
  in {
    home.file.".config/maki/playwright-mcp.json".text = builtins.toJSON playwrightConfig + "\n";
    home.file.".config/maki/mcp.toml".source =
      pkgs.writers.writeTOML "maki-mcp.toml" mcpServers;
  };

  flake.modules.nixos."programs/maki" = {...}: {
    sops.secrets."github-pat" = {
      owner = username;
      mode = "0400";
    };
  };
}
