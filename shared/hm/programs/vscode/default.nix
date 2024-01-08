{
  pkgs,
  lib,
  inputs,
  config,
  ...
}: let
  extensions = inputs.nix-vscode-extensions.extensions.${pkgs.system};
in {
  home.sessionVariables = {EDITOR = "code";};

  programs.vscode = {
    enable = true;
    package = pkgs.vscode.override {
      commandLineArgs = ''--password-store="gnome" --enable-features=UseOzonePlatform --ozone-platform=wayland'';
    };
    enableUpdateCheck = false;
    enableExtensionUpdateCheck = false;
    extensions = with extensions.vscode-marketplace; [
      # Language support
      jnoortheen.nix-ide # Nix LSP Support
      extensions.vscode-marketplace.eww-yuck.yuck # EWW Widgets support
      shd101wyy.markdown-preview-enhanced # Markdown support
      yoavbls.pretty-ts-errors # Readable typescipt errors
      redhat.vscode-yaml # YAML Support
      formulahendry.auto-rename-tag # HTML rename support
      mikestead.dotenv

      # Intellisense
      christian-kohler.path-intellisense # Auto-complete paths
      christian-kohler.npm-intellisense # Auto-complete npm package names
      zignd.html-css-class-completion # Auto-complete CSS class names

      # Visual
      pkief.material-product-icons # Better Icons
      aaron-bond.better-comments # Support coloring TODO's
      esbenp.prettier-vscode # Code formatting
      mechatroner.rainbow-csv # Readable CSV's

      # Utilites
      ms-vsliveshare.vsliveshare # Share Session
      # tailscale.vscode-tailscale # Support for tailscale hosts
      ms-vscode-remote.remote-ssh # Remote SSH development
      eamodio.gitlens # Better git tooling
      streetsidesoftware.code-spell-checker # Spell checker
      mkhl.direnv # Support direnv for project-specifc configuration
    ];
    userSettings = {
      # General Config
      files.autoSave = "onFocusChange";
      editor.formatOnSave = true;
      explorer.confirmDelete = false;
      explorer.confirmDragAndDrop = false;
      security.workspace.trust.untrustedFiles = "open";

      "extensions.autoUpdate" = false;
      "extensions.autoCheckUpdates" = false;
      "update.mode" = "none";

      # Theme Config
      #      workbench.colorTheme
      window.titleBarStyle = "custom";
      workbench.layoutControl.enabled = false;
      editor.fontLigatures = true;
      editor.guides.bracketPairs = "active";

      # Inlays
      editor.inlayHints.enabled = "on";
      javascript.inlayHints = {
        parameterNames.enabled = "all";
        variableTypes.enabled = true;
        parameterTypes.enabled = true;
        propertyDeclarationTypes.enabled = true;
        functionLikeReturnTypes.enabled = true;
      };
      typescript.inlayHints = {
        parameterNames.enabled = "all";
        variableTypes.enabled = true;
        propertyDeclarationTypes.enabled = true;
        parameterTypes.enabled = true;
        functionLikeReturnTypes.enabled = true;
      };

      # Testing fixing them with catppuccin
      workbench.colorCustomizations = {
        "[Stylix]" = {
          "statusBar.background" = "#${config.lib.stylix.colors.base01}";
          "scrollbarSlider.activeBackground" = "#${config.lib.stylix.colors.base04}aa";
          "scrollbarSlider.background" = "#${config.lib.stylix.colors.base02}88";
          "scrollbarSlider.hoverBackground" = "#${config.lib.stylix.colors.base03}88";
        };
      };

      # Spell Checker Config
      # cSpell.enableFiletypes = [ "nix" ];

      # Git Config
      git.confirmSync = false;
      git.autofetch = true;
      git.autoStash = true;
      gitlens = {
        showWelcomeOnInstall = false;
        ai.experimental.generateCommitMessage.enabled = false;
        defaultGravatarsStyle = "identicon";
        showWhatsNewAfterUpgrades = false;
        plusFeatures.enabled = false;
        currentLine.enabled = false;
        views.commitDetails.avatars = false;
        cloudPatches.enabled = false;
        graph.avatars = false;
        graph.minimap.enabled = false;
      };

      # Disable all telemetry
      gitlens.telemetry.enabled = false;
      telemetry.telemetryLevel = "off";
      redhat.telemetry.enabled = false;

      # Nix LSP Config
      nix.enableLanguageServer = true;
      nix.serverPath = lib.getExe pkgs.nil;
      nix.serverSettings = {
        nil = {
          formatting.command = [(lib.getExe pkgs.alejandra)];
          nix.binary = "nix";
          nix.maxMemoryMB = 2560;
          nix.flake.autoArchive = true;
          nix.flake.autoEvalInputs = true;
          nix.flake.nixpkgsInputName = "nixpkgs";
        };
      };
    };
  };
}
