{config, ...}: {
  hardware.nvidia = {
    # Modesetting is needed for most wayland compositors
    modesetting.enable = true;

    # Use the open source version of the kernel module
    # Only available on driver 515.43.04+
    open = false;

    # Enable the nvidia settings menu
    nvidiaSettings = false;

    # Can fix screen tearing on X11
    forceFullCompositionPipeline = false;

    # Optionally, you may need to select the appropriate driver version for your specific GPU.
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };

  # Enable Hyprland fixes for Nvidia
  programs.hyprland.enableNvidiaPatches = true;
  environment.sessionVariables.WLR_NO_HARDWARE_CURSORS = "1";
}
