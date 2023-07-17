# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, ... }:

{
  imports =
    [
      # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./shares-configuration.nix
    ];

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
  };
  boot = {
    loader = {
      timeout = lib.mkDefault 0;
      efi.canTouchEfiVariables = true;
      systemd-boot = {
        enable = true;
        editor = false;
        configurationLimit = 100;
      };
    };
  };

  # Shell
  programs.fish.enable = true;

  networking.hostName = "sirius"; # Define your hostname.
  #  networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "America/Halifax";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_CA.UTF-8";

  # Enable the X11 windowing system.
  services.xserver = {
    enable = true;
    excludePackages = [ pkgs.xterm ];
  };

  # Enable the KDE Plasma Desktop Environment.
  services.xserver = {
    # SDDM
    # sddm.enable = true;

    # LightDM
    # lightdm = {
    #   enable = true;
    #   greeters.slick.enable = true;
    # };

    # GDM
    displayManager.gdm = {
      enable = true;
      wayland = true;
    };

    desktopManager.plasma5.enable = true;
    displayManager.defaultSession = "plasmawayland";
  };
  environment.plasma5.excludePackages = with pkgs.libsForQt5; [
    elisa
    gwenview
    okular
    oxygen
    khelpcenter
    # konsole
    # plasma-browser-integration
    # print-manager
  ];
  programs.dconf.enable = true; # Only needed for gnome apps (like GDM)
  programs.xwayland.enable = true; # Enable XWayland support
  programs.kdeconnect.enable = true;

  # Configure keymap in X11
  services.xserver = {
    layout = "us";
    xkbVariant = "";
  };

  # Enable other packing formats
  services.flatpak.enable = true;

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable blueooth
  hardware.bluetooth = {
    enable = true;
    settings = { General = { Enable = "Source,Sink,Media,Socket"; }; };
  };
  # Enable sound with pipewire.
  sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    wireplumber.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable Nvidia GPU Support
  hardware.opengl = {
    enable = true;
    driSupport = true;
    driSupport32Bit = true;
  };

  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.nvidia = {

    # Modesetting is needed for most wayland compositors
    modesetting.enable = true;

    # Use the open source version of the kernel module
    # Only available on driver 515.43.04+
    open = false;

    # Enable the nvidia settings menu
    nvidiaSettings = true;

    # Optionally, you may need to select the appropriate driver version for your specific GPU.
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };

  # Virtualization
  virtualisation.libvirtd.enable = true;
  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.ben = {
    isNormalUser = true;
    description = "Ben Shewan";
    extraGroups = [ "networkmanager" "wheel" ];
    shell = pkgs.fish;
    packages = with pkgs; [
      firefox
      kate
      vivaldi
      vivaldi-ffmpeg-codecs
      plex-media-player
      jetbrains.webstorm
      # vscode and any extensions
      (vscode-with-extensions.override {
        vscode = vscodium;
        vscodeExtensions = with vscode-extensions; [
          jnoortheen.nix-ide
        ];
      })
      nixpkgs-fmt # Needed for nix formatting in scode
    ];
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    git
    libsForQt5.plasma-browser-integration # Might not get needed, look into fixing browser integration
    lightly-qt
    mpv
    virt-manager
  ];

  # Fonts
  fonts.fonts = [
    pkgs.jetbrains-mono
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Nix configuration
  nix = {
    nixPath = [ "nixos-config=/home/ben/.nix/configuration.nix" ];
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

