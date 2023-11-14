{
  outputs,
  inputs,
  lib,
  config,
  ...
}: {
  imports =
    [
      ./programs
      ./themes
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
}
