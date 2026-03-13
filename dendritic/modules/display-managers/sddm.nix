{...} @ flake: {
  flake.modules.nixos."display-managers/sddm" = {
    pkgs,
    lib,
    config,
    ...
  }: {
    # services.xserver.displayManager.lightdm.enable = lib.mkDefault false;
    # services.sddm = {
    #   enable = true;
    #   wayland.enable = true;
    # };
    imports = [flake.inputs.silentSDDM.nixosModules.default];
    programs.silentSDDM = {
      enable = true;
      theme = "rei";
      backgrounds = {
        default = config.stylix.image;
      };
      profileIcons = let
        avatarFile =
          if flake.config.flake.meta.user.avatar.source != null
          then flake.config.flake.meta.user.avatar.source
          else
            pkgs.fetchurl {
              inherit (flake.config.flake.meta.user.avatar) url sha256;
            };
      in {
        "${flake.config.flake.meta.user.username}" = avatarFile;
      };
      settings = {
        LoginScreen.background = config.stylix.image;
      };
    };
  };
}
