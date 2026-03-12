{inputs, ...}: {
  flake.modules.nixos."display-managers/sddm" = {
    pkgs,
    lib,
    ...
  }: {
    # services.xserver.displayManager.lightdm.enable = lib.mkDefault false;
    # services.sddm = {
    #   enable = true;
    #   wayland.enable = true;
    # };
    imports = [inputs.silentSDDM.nixosModules.default];
    programs.silentSDDM = {
      enable = true;
      theme = "rei";
      # settings = { ... }; see example in module
    };
  };
}
