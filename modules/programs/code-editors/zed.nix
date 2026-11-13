{config, ...}: let
  flakePath = config.flake.meta.flake-path;
in {
  flake.modules.homeManager."programs/zed" = {
    pkgs,
    lib,
    ...
  }: {
    programs.zed-editor = {
      enable = true;
      extensions = [
        # Languages
        "git-firefly" # git syntax support
        "nix" # nix LSP support
        "ini" # ini/config language support
        "angular" # Angular support
        "lua" # Lua support
        "xml" # XML support
        "csharp" # C# support
        # Comfort
        "comment" # Hightlight special comments eg. TODO
        "codebook" # Spell checker
        "rainbow-csv" # make CSVs readable
        "colored-zed-icons-theme" # pretty icons
      ];
      userSettings = {
        # Telemetry
        telemetry = {
          diagnostics = false;
          metrics = false;
        };

        # Workspace
        session = {
          trust_all_worktrees = true;
        };

        # General
        always_treat_brackets_as_autoclosed = true;
        focus_follows_mouse = {
          enabled = true;
          debounce_ms = 0;
        };
        extend_comment_on_newline = false;
        autosave = "on_focus_change";

        # Colab
        collaboration_panel.button = false;

        # Apperance
        buffer_font_size = lib.mkForce 14.0; # Override stylix font size
        title_bar.show_sign_in = false;
        icon_theme = "Colored Zed Icons Theme Dark";
        colorize_brackets = true;
        indent_guides.coloring = "indent_aware";
        toolbar = {
          breadcrumbs = false;
          quick_actions = false;
        };

        # Nix language support
        lsp.nixd = {
          binary.path = lib.getExe pkgs.nixd;
          settings = {
            nixd = {
              nixpkgs.expr = "import (builtins.getFlake \"${flakePath}\").inputs.nixpkgs { }";
              formatting.command = [(lib.getExe pkgs.alejandra)];
              options = {
                nixos.expr = "let fl = builtins.getFlake \"${flakePath}\"; in fl.nixosConfigurations.caelum.options // fl.nixosConfigurations.navis.options";
                home-manager.expr = "let fl = builtins.getFlake \"${flakePath}\"; in fl.nixosConfigurations.caelum.options.home-manager.users.type.getSubOptions [] // fl.nixosConfigurations.navis.options.home-manager.users.type.getSubOptions []";
              };
            };
          };
        };
        languages = {
          Nix = {
            language_servers = ["nixd" "!nil"];
            format_on_save = "on";
            formatter.external = {
              command = lib.getExe pkgs.alejandra;
              arguments = ["--quiet" "--"];
            };
          };
        };

        # JavaScript Support
        languages.JavaScript = {
          formatter.external = {
            "command" = lib.getExe pkgs.biome;
            "arguments" = ["format" "--stdin-file-path" "{buffer_path}"];
          };
          code_actions_on_format = {
            "source.fixAll.eslint" = true;
          };
        };

        # CSV Support
        languages.CSV = {
          soft_wrap = "none";
        };
        # AI
        language_models.openai_compatible.Orion = {
          api_url = "http://192.168.2.39:8433/v1";
          available_models = [
            {
              name = "unsloth/gemma-4-E4B-it-GGUF";
              max_tokens = 200000;
              max_output_tokens = 32000;
              max_completion_tokens = 200000;
              capabilities = {
                tools = true;
                images = true;
                parallel_tool_calls = false;
                prompt_cache_key = false;
                chat_completions = true;
              };
            }
          ];
        };
        edit_predictions = {
          open_ai_compatible_api = {
            max_output_tokens = 64;
            model = "unsloth/gemma-4-E4B-it-GGUF";
            api_url = "http://192.168.2.39:8433/v1";
          };
          provider = "open_ai_compatible_api";
        };
        agent = {
          use_modifier_to_send = true;
          thinking_display = "always_collapsed";
          default_model = {
            provider = "Orion";
            model = "unsloth/gemma-4-E4B-it-GGUF";
            enable_thinking = true;
          };

          model_parameters = [];
          enable_feedback = false;
        };

        auto_update = false;
      };
    };
  };
}
