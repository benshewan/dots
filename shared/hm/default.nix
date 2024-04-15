{
  outputs,
  inputs,
  lib,
  ...
}: {
  imports =
    [
      inputs.stylix.homeManagerModules.stylix
      ./services/flatpak
    ]
    ++ (builtins.attrValues outputs.homeManagerModules)
    ++ [./theme/kvantum];

  # default theme
  stylix.targets.kvantum.enable = true;

  # add in any overlays
  nixpkgs.overlays = builtins.attrValues outputs.overlays ++ [inputs.nur.overlay];

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  # Allow unfree software
  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.allowUnfreePredicate = _: true;

  # This will add each flake input as a registry
  # To make nix3 commands consistent with your flake
  nix.registry = lib.mapAttrs (_: value: {flake = value;}) inputs;

  # This will additionally add your inputs to the system's legacy channels
  home.sessionVariables = {
    NIX_PATH = "nixpkgs=${inputs.nixpkgs}";
  };

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";

  # Basic Aliases
  home.shellAliases = {
    sudo = "sudo -E";
    sudopath = "sudo env PATH=$PATH";
  };

  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = "${config.night-sky.user.name}";
  home.homeDirectory = "/home/${config.night-sky.user.name}";

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "23.05";
}
