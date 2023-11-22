{
  outputs,
  inputs,
  lib,
  config,
  pkgs,
  ...
}: {
  imports =
    [
      ./programs
      # ./themes
      ./themes/qt.nix
      inputs.stylix.homeManagerModules.stylix
      inputs.nix-colors.homeManagerModules.default
    ]
    ++ (builtins.attrValues outputs.homeManagerModules);

  nixpkgs.overlays = builtins.attrValues outputs.overlays ++ [inputs.nur.overlay];
  # This will add each flake input as a registry
  # To make nix3 commands consistent with your flake
  nix.registry = lib.mapAttrs (_: value: {flake = value;}) inputs;

  # This will additionally add your inputs to the system's legacy channels
  home.sessionVariables = {
    NIX_PATH = "nixpkgs=${inputs.nixpkgs}";
  };

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";

  # Testing new theme config stuff

  # Will generate a theme from wallpaper if none is provided ../../wallpapers/catppuccin-floral.png
  stylix.image = "${outputs.wallpapers}/catppuccin-floral.png";
  stylix.polarity = "dark";
  stylix.base16Scheme = "${pkgs.base16-schemes}/share/themes/catppuccin-mocha.yaml";
  stylix.targets.kde.enable = true;
  stylix.cursor = {
    name = "Catppuccin-Mocha-Dark-Cursors";
    package = pkgs.catppuccin-cursors.mochaDark;
    size = 32;
  };
  # Fonts
  stylix.fonts = {
    # serif = {
    #   package = pkgs.dejavu_fonts;
    #   name = "DejaVu Serif";
    # };
    serif = config.stylix.fonts.sansSerif;

    sansSerif = {
      # package = pkgs.dejavu_fonts;
      # name = "DejaVu Sans";
      package = pkgs.nerdfonts.override {fonts = ["DejaVuSansMono"];};
      name = "DejaVuSansMono";
    };

    monospace = {
      package = pkgs.nerdfonts.override {fonts = ["JetBrainsMono"];};
      name = "JetBrainsMono";
    };

    emoji = {
      package = pkgs.noto-fonts-emoji;
      name = "Noto Color Emoji";
    };
  };
}
