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
          active-border-color = "#FF0000";
          inactive-border-color = "#FFFF00";
        };
        "LoginScreen.LoginArea.Username" = {
          color = "#FFF";
        };
        "LoginScreen.LoginArea.PasswordInput" = {
          content-color = "#000";
          background-color = "#FFF";
          border-color = "#FF00FF";
          masked-character = "●";
        };
      };
    };
  };
}
