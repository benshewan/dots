{
  pkgs,
  lib,
  inputs,
  config,
  ...
}: let
  extensions = inputs.nix-vscode-extensions.extensions.x86_64-linux;
in {
  home.sessionVariables = {EDITOR = "codium";};
  programs.vscode = {
    enable = true;
    package = pkgs.vscodium.override {
      commandLineArgs = ''--password-store="gnome"'';
    };
    enableUpdateCheck = false;
    enableExtensionUpdateCheck = false;
    extensions = with pkgs.vscode-extensions; [
      jnoortheen.nix-ide
      catppuccin.catppuccin-vsc
      pkief.material-product-icons
      streetsidesoftware.code-spell-checker
      mkhl.direnv
      # extensions.vscode-marketplace.golf1052.base16-generator
    ];
    userSettings = {
      # General Config
      files.autoSave = "onFocusChange";
      editor.formatOnSave = true;
      explorer.confirmDelete = false;

      # Theme Config
      workbench.colorTheme = "Catppuccin Mocha";
      window.titleBarStyle = "custom";

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
