{
  inputs,
  lib,
  config,
  ...
}: let
  # Flake-level user metadata; config.flake does not exist inside the NixOS
  # module below, which shadows `config` with the host config.
  username = config.flake.meta.user.username;
in {
  flake-file.inputs = {
    stylix.url = "github:danth/stylix";
    stylix.inputs.nixpkgs.follows = "nixpkgs";
  };
  flake.modules.nixos."system/stylix" = {
    imports = [inputs.stylix.nixosModules.stylix];
    stylix.enable = lib.mkDefault true;

    # With stylix.autoEnable on (its default), every target it has a module
    # for is themed, and a handful of targets write their configs without
    # checking whether the app is installed at all. Silence those here;
    # apps that are actually enabled keep being themed automatically.
    # (Targets that gate on programs.<app>.enable need no entry.)
    home-manager.users.${username}.stylix.targets = {
      blender.enable = false;
      vencord.enable = false;
      forge.enable = false;
      gdu.enable = false;
      gedit.enable = false;
    };
  };
}
