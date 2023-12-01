{
  pkgs,
  lib,
  inputs,
  config,
  ...
}: let
  extensions = inputs.nix-vscode-extensions.extensions.x86_64-linux;
in {
  home.sessionVariables = {EDITOR = "code";};

  programs.vscode = {
    enable = true;
    package = pkgs.vscode.override {
      commandLineArgs = ''--password-store="gnome" --enable-features=UseOzonePlatform --ozone-platform=wayland'';
    };
    enableUpdateCheck = false;
    enableExtensionUpdateCheck = false;
    extensions = with pkgs.vscode-extensions; [
      jnoortheen.nix-ide
      pkief.material-product-icons
      ms-vsliveshare.vsliveshare
      streetsidesoftware.code-spell-checker
      mkhl.direnv
      # extensions.vscode-marketplace.golf1052.base16-generator
    ];
    userSettings = {
      # General Config
      files.autoSave = "onFocusChange";
      editor.formatOnSave = true;
      explorer.confirmDelete = false;
      extensions.autoCheckUpdates = false;
      explorer.confirmDragAndDrop = false;
      update.mode = "none";

      # Theme Config
      #      workbench.colorTheme
      window.titleBarStyle = "custom";
      workbench.layoutControl.enabled = false;
      editor.fontLigatures = true;

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
