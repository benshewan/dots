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
        default = config.flake.stylix.image;
      };
      profileIcons = {
        "${flake.config.flake.meta.user.username}" = flake.config.flake.meta.user.avatar;
      };
      # settings = {
      #   # LockScreen.background =
      # };
    };
  };
}
