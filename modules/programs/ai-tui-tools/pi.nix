{...}: {
  flake.modules.homeManager."programs/pi" = {
    pkgs,
    lib,
    config,
    ...
  }: {
    # Route pi-lens into proper XDG dirs instead of polluting ~ with ~/.pi-lens.
    # pi-lens reads these three env vars at process start (it honors no config
    # key equivalent); every ~/.pi-lens path resolves through them:
    #   PI_LENS_HOME        -> global logs, managed tool binaries, instance registry
    #   PI_LENS_CONFIG_PATH -> the global config.json
    #   PILENS_DATA_DIR     -> per-project caches/snapshots/review-graph
    home.sessionVariables = {
      PI_LENS_HOME = "${config.xdg.stateHome}/pi-lens";
      PI_LENS_CONFIG_PATH = "${config.xdg.configHome}/pi-lens/config.json";
      PILENS_DATA_DIR = "${config.xdg.dataHome}/pi-lens";
    };

    programs.pi-coding-agent = {
      enable = true;
      configDir = "${config.xdg.configHome}/pi/agent";

          settings = {
            defaultModel = "deepseek-v4-flash";
            theme = "terminal";
            enableInstallTelemetry = false;
            quietStartup = true;
            subagents = {
              # Default for every subagent that doesn't pin its own model
              defaultModel = "deepseek-v4-flash";
              agentOverrides = {
                oracle.model = "glm-5.2";
                reviewer.model = "glm-5.2";
              };
            };
            packages = [
              # Centralized settings management; adds /extension-settings commands (must load before other extensions)
              "npm:@juanibiapina/pi-extension-settings"
              # Single-agent delegation and scripted multi-agent workflows
              "npm:pi-subagents"
              # Interactive ask_user tool with searchable selection UI, multi-select, and freeform input
              "npm:pi-ask-user"
              # MCP (Model Context Protocol) adapter extension
              "npm:pi-mcp-adapter"
              # Web search, URL fetching, GitHub repo cloning, PDF extraction, and YouTube/video analysis
              "npm:pi-web-access"
              # Letta-like git-backed markdown memory management, persistent across sessions
              "git:github.com/VandeeFeng/pi-memory-md"
              # Read-only planning mode with approval-based execution
              "npm:@devkade/pi-plan"
              # Reviews recently changed code for clarity, consistency, and maintainability
              "npm:pi-simplify"
              # LSP diagnostics, lint/type-check on write, symbol search, AST rules, and impact cascade
              "npm:pi-lens"
              # Add external directories to the session; loads their AGENTS.md, CLAUDE.md, and skills
              "npm:pi-add-dir"
              # Terminal-native code review and annotation workflow
              "npm:pi-slopchop"
              # Persistent powerline status bar with event-updated left/right segments
              "npm:@juanibiapina/pi-powerbar"
              # Claude Code-style task tracking and coordination
              "npm:@tintinweb/pi-tasks"
              # Run AI coding agents in Pi TUI overlays with interactive/hands-free supervision
              "npm:pi-interactive-shell"
              # Autonomous experiment loop extension
              "git:github.com/davebcn87/pi-autoresearch"
              # Terminal themes using ANSI 0..15, with optional tinted variant
              "npm:pi-terminal-theme"
            ];
          };
    };
  };
}
