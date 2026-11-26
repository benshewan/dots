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

  # Core maki HM module; flake-parts merges mcp.nix (MCP servers) and theme.nix
  # (stylix theme, self-disabling without stylix) into this same module.
  flake.modules.homeManager."programs/maki" = {
    pkgs,
    lib,
    config,
    ...
  }: let
    inherit (lib) types;
    inherit (flake.config.flake.lib) mkOpt;

    maki = inputs.maki.packages.${pkgs.stdenv.hostPlatform.system}.default;
  in {
    # maki.setup() table rendered into init.lua below; companion files merge
    # into it (theme.nix adds ui.theme) and hosts can override any key.
    options.modules.maki.setup =
      mkOpt (types.attrsOf types.anything) {}
      "Attrset merged into the maki.setup() call rendered to ~/.config/maki/init.lua.";

    # Declaring `options` requires the config body under an explicit `config`.
    config = {
      modules.maki.setup = {
        always_yolo = true;
        agent.compaction_buffer = "10%";
        provider.default_model = "opencode-go/deepseek-v4.1-flash";
        plugins.completion.enabled = true;
      };

      home.packages = [
        maki
        # rtk: CLI proxy that trims dev-command output; the agent burns fewer tokens.
        pkgs.rtk
      ];

      # Builtin websearch needs EXA_API_KEY in the env; see the sops template below.
      home.sessionVariablesExtra = ''
        [ -r "${exaEnvPath}" ] && . "${exaEnvPath}"
      '';

      home.file.".config/maki/init.lua".text = ''
        -- Managed by Nix; extend modules.maki.setup, not this file.
        maki.setup(${lib.generators.toLua {} config.modules.maki.setup})
        require("usage_hud")
      '';

      home.file.".config/maki/AGENTS.md".source = ./INITIAL_PROMPT.md;

      # Usage HUD plugin: one line with the selected provider's plan limits
      # (maki.provider.usage) above the input; covers any provider.
      home.file.".config/maki/lua/usage_hud.lua".source = ./custom-plugins/usage_hud.lua;

      # The usage plugins read their data from maki.provider.usage (maki's
      # own fetch), so nothing calls a gated API anymore; the file stays for
      # the version floor.
      home.file.".config/maki/plugin.toml".source = pkgs.writers.writeTOML "maki-plugin.toml" {
        min_maki_version = "0.7.0";
      };
    };
  };

  flake.modules.nixos."programs/maki" = {config, ...}: {
    sops.secrets."exa-api-key" = {};

    sops.templates."maki-env" = {
      owner = username;
      mode = "0400";
      content = "export EXA_API_KEY=\"${config.sops.placeholder."exa-api-key"}\"\n";
    };
  };

  # Preservation companion for "programs/maki" (auto-resolved by the prefix).
  flake.modules.nixos."preservation/programs/maki" = {config, ...}: {
    preservation.preserveAt.${config.modules.preservation.persistentPath}.users.${username}.directories = [
      # Mostly HM-rendered; preserved for maki's own runtime writes.
      {
        directory = ".config/maki";
        mode = "0700";
      }

      # Provider credentials, session history, project memories, browser
      # output. Regenerable logs (~/.local/logs/maki) stay volatile.
      {
        directory = ".local/state/maki";
        mode = "0700";
      }
    ];
  };
}
