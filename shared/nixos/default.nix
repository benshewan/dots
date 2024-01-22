{
  inputs,
  pkgs,
  outputs,
  config,
  lib,
  ...
}: {
  imports =
    [
      # Load inputs
      inputs.stylix.nixosModules.stylix
      inputs.nix-index-database.nixosModules.nix-index
    ]
    ++ (builtins.attrValues outputs.nixosModules);

  # ---------- TESTING CHANGES ----------
  # Fixing theme
  # environment.sessionVariables = {
  #   QT_QPA_PLATFORMTHEME = "qt5ct";
  # };
  qt = {
    enable = true;
    platformTheme = "qt5ct";
    # style = {
    #   package = pkgs.catppuccin-kvantum;
    #   name = "Catppuccin-Macchiato-Blue";
    # };
  };
  # ---------- TESTING CHANGES ----------

  # Boot Configuration
  boot = {
    # Plymouth
    kernelParams = ["quiet" "splash"];
    initrd.systemd.enable = true;
    consoleLogLevel = 0;
    initrd.verbose = false;
    plymouth.enable = true;

    # Systemd-boot
    loader = {
      timeout = lib.mkDefault 5;
      efi.canTouchEfiVariables = true;
      systemd-boot = {
        enable = true;
        editor = false;
        consoleMode = "auto";
        configurationLimit = 25;
      };
    };
  };

  networking.networkmanager.enable = true;

  # Firmware / Kernel
  boot.kernelPackages = lib.mkDefault pkgs.linuxPackages_latest;
  hardware.enableAllFirmware = true;

  # Set your time zone.
  time.timeZone = "America/Halifax";

  users = {
    defaultUserShell = pkgs.fish;
    groups = {
      "${outputs.username}" = {};
    };
    users.${outputs.username} = {
      isNormalUser = true;
      description = outputs.userDescription;
      initialPassword = "admin";
      extraGroups = ["wheel" "docker" "video" "libvirtd" "plugdev" "${outputs.username}"];
    };
  };

  # Add support for ~/.local/bin
  environment.localBinInPath = true;

  # Shell
  environment.shellAliases = {
    reboot = "systemctl reboot";
    nix-switch = "sudo nixos-rebuild switch --flake ${outputs.flake-path}#${config.networking.hostName}";
    home-switch = "home-manager switch --flake ${outputs.flake-path}#${outputs.username}@${config.networking.hostName}";
  };

  # NixOS Stuff
  nixpkgs.config.allowUnfree = true;

  programs.nix-ld.enable = true;

  nix = {
    settings.experimental-features = ["nix-command" "flakes"];
    settings.auto-optimise-store = true;
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };
    # This will add each flake input as a registry
    # To make nix3 commands consistent with your flake
    registry = lib.mapAttrs (_: value: {flake = value;}) inputs;

    # This will additionally add your inputs to the system's legacy channels
    # Making legacy nix commands consistent as well, awesome!
    nixPath = lib.mapAttrsToList (key: value: "${key}=${value.to.path}") config.nix.registry;
  };

  nixpkgs.overlays = builtins.attrValues outputs.overlays ++ [inputs.nur.overlay];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).

  system.stateVersion = "23.05"; # Did you read the comment?
}
