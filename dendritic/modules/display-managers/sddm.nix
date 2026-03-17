{...} @ flake: {
  flake.modules.nixos."display-managers/sddm" = {
    pkgs,
    lib,
    config,
    ...
  }: let
    avatarFile =
      if flake.config.flake.meta.user.avatar.source != null
      then flake.config.flake.meta.user.avatar.source
      else
        pkgs.fetchurl {
          inherit (flake.config.flake.meta.user.avatar) url sha256;
        };

    colors = config.lib.stylix.colors.withHashtag;
  in {
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
      profileIcons = {
        "${flake.config.flake.meta.user.username}" = avatarFile;
      };
      settings = {
        # Lock Screen
        "LockScreen" = {
          background = builtins.baseNameOf config.stylix.image;
          display = false;
        };

        # Login Screen
        "LoginScreen" = {
          background = builtins.baseNameOf config.stylix.image;
        };
        "LoginScreen.LoginArea.Avatar" = {
          active-border-color = colors.base02;
          inactive-border-color = colors.base01;
        };
        "LoginScreen.LoginArea.Username" = {
          color = colors.base05;
        };
        "LoginScreen.LoginArea.PasswordInput" = {
          content-color = colors.base04;
          background-color = colors.base01;
          border-color = "#FF00FF";
          masked-character = "●";
        };
      };
    };
  };
}
