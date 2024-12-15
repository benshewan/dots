{
  pkgs,
  lib,
  inputs,
  config,
  host,
  ...
}: let
  extensions = inputs.nix-vscode-extensions.extensions.${pkgs.system};
  font = "'${config.stylix.fonts.monospace.name}'";
in {
  home.sessionVariables = {EDITOR = "code";};

  programs.vscode = {
    enable = true;
    package = pkgs.vscode.override {
      commandLineArgs = ''--password-store=gnome-libsecret --enable-features=UseOzonePlatform --ozone-platform=wayland'';
    };
    enableUpdateCheck = false;
    enableExtensionUpdateCheck = false;
    extensions =
      (with extensions.vscode-marketplace; [
        # Language support
        jnoortheen.nix-ide # Nix LSP Support
        eww-yuck.yuck # EWW Widgets support
        shd101wyy.markdown-preview-enhanced # Markdown support
        yoavbls.pretty-ts-errors # Readable typescipt errors
        redhat.vscode-yaml # YAML Support
        mikestead.dotenv
        svelte.svelte-vscode
        bradlc.vscode-tailwindcss

        # Intellisense
        # formulahendry.auto-rename-tag # HTML rename support
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
        ms-vscode-remote.remote-containers # Support for dev containers
        # github.vscode-pull-request-github # Better pull request
        arturock.gitstash # Better git stash UI
        ritwickdey.liveserver # Spin up a basic server
        # tailscale.vscode-tailscale # Support for tailscale hosts
        ms-vscode-remote.remote-ssh # Remote SSH development
        eamodio.gitlens # Better git tooling
        streetsidesoftware.code-spell-checker # Spell checker
        mkhl.direnv # Support direnv for project-specifc configuration
      ])
      ++ (with extensions.open-vsx; [
        # svelte.svelte-vscode
      ])
      ++ (with pkgs.vscode-extensions; [
        github.vscode-pull-request-github
      ]);
    userSettings = {
      # General Config
      "files.autoSave" = "onFocusChange";
      "editor.formatOnSave" = true;
      "explorer.confirmDelete" = false;
      "explorer.confirmDragAndDrop" = false;
      "security.workspace.trust.untrustedFiles" = "open";
      "editor.stickyScroll.enabled" = false;
      "editor.linkedEditing" = true;

      "extensions.autoUpdate" = false;
      "extensions.autoCheckUpdates" = false;
      "update.mode" = "none";

      # Theme Config
      "window.titleBarStyle" = "custom";
      "workbench.layoutControl.enabled" = false;
      "editor.fontLigatures" = true;
      # "editor.fontFamily" = font;
      # "terminal.integrated.fontFamily" = font;
      "editor.guides.bracketPairs" = "active";

      # Inlays
      "editor.inlayHints.enabled" = "on";

      "javascript.inlayHints.parameterNames.enabled" = "all";
      "javascript.inlayHints.variableTypes.enabled" = true;
      "javascript.inlayHints.parameterTypes.enabled" = true;
      "javascript.inlayHints.propertyDeclarationTypes.enabled" = true;
      "javascript.inlayHints.functionLikeReturnTypes.enabled" = true;

      "typescript.inlayHints.parameterNames.enabled" = "all";
      "typescript.inlayHints.variableTypes.enabled" = true;
      "typescript.inlayHints.propertyDeclarationTypes.enabled" = true;
      "typescript.inlayHints.parameterTypes.enabled" = true;
      "typescript.inlayHints.functionLikeReturnTypes.enabled" = true;

      # Spell Checker Config
      # cSpell.enableFiletypes = [ "nix" ];

      # Git Config
      "git.confirmSync" = false;
      "git.autofetch" = true;
      "git.autoStash" = true;

      "gitlens.showWelcomeOnInstall" = false;
      "gitlens.ai.experimental.generateCommitMessage.enabled" = false;
      "gitlens.defaultGravatarsStyle" = "identicon";
      "gitlens.showWhatsNewAfterUpgrades" = false;
      "gitlens.plusFeatures.enabled" = false;
      "gitlens.currentLine.enabled" = false;
      "gitlens.views.commitDetails.avatars" = false;
      "gitlens.cloudPatches.enabled" = false;
      "gitlens.graph.avatars" = false;
      "gitlens.graph.minimap.enabled" = false;
      "gitlens.launchpad.indicator.enabled" = false;

      "githubPullRequests.createOnPublishBranch" = "never";

      # Disable all telemetry
      "gitlens.telemetry.enabled" = false;
      "telemetry.telemetryLevel" = "off";
      "redhat.telemetry.enabled" = false;

      # Svelte Config
      "svelte.enable-ts-plugin" = true;

      # Live Server Config
      "liveServer.settings.donotShowInfoMsg" = true;

      # Prettier Config
      "editor.defaultFormatter" = "esbenp.prettier-vscode";

      # Nix LSP Config
      "nix.enableLanguageServer" = true;
      "nix.serverPath" = lib.getExe pkgs.nixd;
      # "nix.serverSettings.nil.formatting.command" = [(lib.getExe pkgs.alejandra)];
      "nix.serverSettings.nixd.formatting.command" = [(lib.getExe pkgs.alejandra)];

      # "nix.serverSettings.nil.nix.binary" = "nix";
      # "nix.serverSettings.nil.nix.maxMemoryMB" = 3072;
      # "nix.serverSettings.nil.nix.flake.autoArchive" = true;
      # "nix.serverSettings.nil.nix.flake.autoEvalInputs" = false;
      # "nix.serverSettings.nil.nix.flake.nixpkgsInputName" = "nixpkgs";

      "nix.serverSettings.nixd.options.home-manager.expr" = "(builtins.getFlake \"${config.night-sky.user.home}/.nix\").homeConfigurations.\"${config.night-sky.user.name}@${host}\".options";
      "nix.serverSettings.nixd.options.nixos.expr" = "(builtins.getFlake \"${config.night-sky.user.home}/.nix\").nixosConfigurations.${host}.options";
      "nix.serverSettings.nixd.options.nixpkgs.expr" = "(builtins.getFlake \"${config.night-sky.user.home}/.nix\").nixosConfigurations.${host}.pkgs";

      "[nix]"."editor.defaultFormatter" = "jnoortheen.nix-ide";
    };
  };
}
