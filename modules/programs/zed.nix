_: {
  flake.modules.homeManager."programs/zed" = {
    pkgs,
    lib,
    ...
  }: {
    programs.zed-editor = {
      enable = true;
      extensions = [
        "nix"
        "colored-zed-icons-theme"
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
        extend_comment_on_newline = false;
        autosave = "on_focus_change";

        # Apperance
        buffer_font_size = lib.mkForce 14.0; # Override stylix font size
        icon_theme = "Colored Zed Icons Theme Dark";
        colorize_brackets = true;
        indent_guides.coloring = "indent_aware";
        toolbar = {
          breadcrumbs = false;
          quick_actions = false;
        };

        # Nix language support
        lsp.nil.binary.path = lib.getExe pkgs.nil;
        languages = {
          Nix = {
            language_servers = ["nil" "!nixd"];
            formatter.external = {
              command = lib.getExe pkgs.alejandra;
              arguments = ["--quiet" "--"];
            };
          };
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
