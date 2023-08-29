# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, ... }:

let
  user = "ben";
  userDescription = "Ben Shewan";
in
{
  imports =
    [
      # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./shares-configuration.nix
    ];

  boot.kernelPackages = pkgs.linuxPackages_latest;
  hardware.enableRedistributableFirmware = true;
  hardware.enableAllFirmware = true;

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
      timeout = lib.mkDefault 5;
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
    # displayManager.sddm.enable = true;

    # LightDM
    # displayManager.lightdm.greeters.mini = {
    #         enable = true;
    #         inherit user;
    #         extraConfig = ''
    #             [greeter]
    #             show-password-label = false
    #             password-alignment = left
    #             show-image-on-all-monitors = true
    #             [greeter-theme]
    #             background-image = "/home/${user}/.local/share/wallpapers/lockscreen.jpeg"
    #             password-border-width = 0px
    #             border-width = 0px

    #             font-size = 1.15em
    #         '';
    #     };

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

  # Desktop portal config
  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-kde
    ];
  };

  programs.dconf.enable = true; # Only needed for gnome apps (like GDM)
  programs.xwayland.enable = true; # Enable XWayland support

  #  KDE Connect plus some magic to get browser integration working
  programs.kdeconnect.enable = true;
  environment.etc."chromium/native-messaging-hosts/org.kde.plasma.browser_integration.json".source = "${pkgs.plasma-browser-integration}/etc/chromium/native-messaging-hosts/org.kde.plasma.browser_integration.json";

  # Configure keymap in X11
  services.xserver = {
    layout = "us";
    xkbVariant = "";
  };

  # Enable other packing formats
  services.flatpak.enable = true;

  # environment.etc = {
  #   "flatpak/remotes.d/flathub.flatpakrepo".source = pkgs.fetchurl {
  #     url = "https://dl.flathub.org/repo/flathub.flatpakrepo";
  #     # Let this run once and you will get the hash as an error.
  #     hash = "";
  #   };
  # };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable blueooth
  hardware.bluetooth = {
    enable = true;
    settings = {
      General = {
        Enable = "Source,Sink,Media,Socket";
        Experimental = "true";
      };
    };
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
    extraPackages = with pkgs; [
      # intel-media-driver # LIBVA_DRIVER_NAME=iHD
      # vaapiIntel         # LIBVA_DRIVER_NAME=i965 (older but works better for Firefox/Chromium)
      vaapiVdpau
      libvdpau-va-gl
    ];
  };

  services.xserver.videoDrivers = [ "nvidia" ];
  services.xserver.screenSection = ''
    Option         "metamodes" "nvidia-auto-select +0+0 {ForceFullCompositionPipeline=On}"
    Option         "AllowIndirectGLXProtocol" "off"
    Option         "TripleBuffer" "on"
  '';


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

  # Enable support for razer devices
  hardware.openrazer.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.${user} = {
    isNormalUser = true;
    description = userDescription;
    extraGroups = [ "networkmanager" "wheel" "openrazer" "docker" "audio" "plugdev" ];
    shell = pkgs.fish;
    packages = with pkgs; [
      kitty
      libsForQt5.kate
      (vivaldi.override {
        proprietaryCodecs = true;
        enableWidevine = true;
        commandLineArgs = "--enable-features=WebUIDarkMode --force-dark-mode";
      })
      plex-media-player
      prismlauncher

      # Development
      mongodb-compass
      jetbrains.webstorm
      # vscode and any extensions
      (vscode-with-extensions.override {
        vscode = vscodium;
        vscodeExtensions = with vscode-extensions; [
          jnoortheen.nix-ide
          catppuccin.catppuccin-vsc
          pkief.material-product-icons
          streetsidesoftware.code-spell-checker
        ];
      })
      nixpkgs-fmt # Needed for nix formatting in vscode
    ];
  };

  # Enable Local MongoDB Server for Development
  services.mongodb.enable = true;
  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Enable wayland support for chromium and most electron apps
  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  # add support for ~/.local/bin
  environment.localBinInPath = true;

  # Enable dark mode in vivaldi
  # nixpkgs.overlays = [
  #   (final: prev: {
  #     vivaldi = prev.vivaldi.override {
  #       commandLineArgs = "--enable-features=WebUIDarkMode --force-dark-mode";
  #       # "--enable-features=TouchpadOverscrollHistoryNavigation";
  #     };
  #   })
  # ];

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    vim
    git
    dig
    toybox
    neofetch
    nodejs_20
    prefetch-npm-deps
    nix-prefetch-github
    bat
    exa
    wget
    razergenie
    (python311.withPackages (ps: with ps; [
      openrazer # Break into seprate flake for battery charge management
      # pygobject3
      # pyqt5
      # ruamel-yaml # Can't find libs in build but can in develop
      # pyinotify
      # pyqtwebengine
    ]))
    firefox
    lightly-qt
    mpv
    virt-manager
  ];

  # Fonts
  fonts.fonts = [
    pkgs.jetbrains-mono
    pkgs.nerdfonts
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
    nixPath = [
      "nixpkgs=/nix/var/nix/profiles/per-user/root/channels/nixos"
      "nixos-config=/home/${user}/.nix/configuration.nix"
      "/nix/var/nix/profiles/per-user/root/channels"
    ];
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

