{ pkgs, ... }:
{

  home.packages = with pkgs; [
    nixpkgs-fmt # Needed for nix formatting in vscode
  ];
  home.sessionVariables = { EDITOR = "codium"; };
  programs.vscode = {
    enable = true;
    package = pkgs.vscodium;
    enableUpdateCheck = false;
    enableExtensionUpdateCheck = false;
    extensions = with pkgs.vscode-extensions; [
      jnoortheen.nix-ide
      catppuccin.catppuccin-vsc
      pkief.material-product-icons
      streetsidesoftware.code-spell-checker
    ];
    userSettings = {
      "workbench.colorTheme" = "Catppuccin Mocha";
      "window.titleBarStyle" = "custom";
      "git.confirmSync"= false;
    };
  };
}
