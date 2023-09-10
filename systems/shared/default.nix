{ lib, pkgs, username, userDescription, ... }:
{
  imports = [
    ./packages.nix
    ./networking.nix
    ./services.nix
    ./hardware.nix
  ];

  # Boot Configuration

  # Hacked together from 
  # https://github.com/NixOS/nixpkgs/issues/32556#issuecomment-1060118989 && https://github.com/NixOS/nixpkgs/issues/32556#issuecomment-1378261367
  console = {
    font = "ter-132n";
    packages = [ pkgs.terminus_font ];
    useXkbConfig = true;
    earlySetup = false;
  };
  boot = {
    kernelParams = [ "quiet" "splash" ];
    plymouth.enable = true;
    consoleLogLevel = 0;
    initrd.verbose = false;

    loader = {
      timeout = lib.mkDefault 5;
      efi.canTouchEfiVariables = true;
      systemd-boot = {
        enable = true;
        editor = false;
        consoleMode = "auto";
        configurationLimit = 100;
      };
    };
  };

  # Firmware / Kernel
  boot.kernelPackages = pkgs.linuxPackages_latest;
  hardware.enableRedistributableFirmware = true;
  hardware.enableAllFirmware = true;

  # Set your time zone.
  time.timeZone = "America/Halifax";

  # Add support for ~/.local/bin
  environment.localBinInPath = true;

  # Enviroment vars
  # environment.sessionVariables = rec {
  #   XDG_CACHE_HOME  = "$HOME/.cache";
  #   XDG_CONFIG_HOME = "$HOME/.config";
  #   XDG_DATA_HOME   = "$HOME/.local/share";
  #   XDG_STATE_HOME  = "$HOME/.local/state";

  #   # Not officially in the specification
  #   XDG_BIN_HOME    = "$HOME/.local/bin";
  #   PATH = [ 
  #     "${XDG_BIN_HOME}"
  #   ];
  # };

  users = {
    defaultUserShell = pkgs.fish;
    groups = {
      "${username}" = { };
    };
    users.${username} = {
      isNormalUser = true;
      description = userDescription;
      initialPassword = "admin";
      extraGroups = [ "wheel" "docker" "video" "libvirtd" "plugdev" "${username}" ];
    };
  };

  # NixOS Stuff
  nixpkgs.config.allowUnfree = true;
  nix = {
    settings.experimental-features = [ "nix-command" "flakes" ];
    settings.auto-optimise-store = true;
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).

  system.stateVersion = "23.05"; # Did you read the comment?
}
