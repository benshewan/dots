{
  lib,
  config,
  namespace,
  ...
}: {
  system.defaults = {
    # Dock Settings

    # Dock AutoHide
    dock.autohide = true;

    # Whether to automatically rearrange spaces based on most recent use
    dock.mru-spaces = false;

    dock.tilesize = 56; # Default size is 64
    dock.slow-motion-allowed = false;

    # Animations
    dock.autohide-time-modifier = 0.75;
    dock.autohide-delay = 0.1;
    NSGlobalDomain.NSScrollAnimationEnabled = false;
    dock.expose-animation-duration = 0.5;
    NSGlobalDomain.NSAutomaticWindowAnimationsEnabled = false;
    NSGlobalDomain.NSUseAnimatedFocusRing = false; # Textbox focusing animation
    NSGlobalDomain.NSWindowResizeTime = 1.0;

    # Hot Corners
    dock.wvous-bl-corner = 1;
    dock.wvous-br-corner = 1;
    dock.wvous-tl-corner = 1;
    dock.wvous-tr-corner = 1;

    # Dock Apps
    dock.persistent-apps = lib.mkDefault [
      "/Applications/Safari.app"
      "/System/Applications/Utilities/Terminal.app"
      # Temp, don't assume
      "/Users/${config.${namespace}.user.name}/Application/Home Manager Trampolines/Visual Studio Code.app"
    ];

    # Finder Settings

    finder._FXSortFoldersFirst = true; # Folders Always on top
    finder.CreateDesktop = false; # Hide icons on desktop
    finder.AppleShowAllFiles = true; # Show hidden files
    finder.AppleShowAllExtensions = true; # Show File Extensions
    finder._FXShowPosixPathInTitle = true; # Show File Path
    finder.FXDefaultSearchScope = "SCcf"; # Search in folder, not across computer
    finder.FXRemoveOldTrashItems = true;
    finder.FXEnableExtensionChangeWarning = false;
    finder.ShowPathbar = true;
    finder.ShowStatusBar = true;

    # Clock
    menuExtraClock.Show24Hour = false;
    menuExtraClock.ShowAMPM = true;
    menuExtraClock.ShowDayOfWeek = true;

    # Control Center
    controlcenter.BatteryShowPercentage = true;
    controlcenter.Bluetooth = true; # Show in menubar

    # Keyboard
    hitoolbox.AppleFnUsageType = "Do Nothing";

    # Mouse
    ".GlobalPreferences"."com.apple.mouse.scaling" = -1.0; # Disable Mouse Acceleration
    trackpad.Clicking = true; # Tap to click
    trackpad.Dragging = true; # Tap to drag

    # Misc
    SoftwareUpdate.AutomaticallyInstallMacOSUpdates = true;
  };

  system.keyboard = {
    enableKeyMapping = true;
    swapLeftCtrlAndFn = true;
  };

  system.startup.chime = false; # Why is it so loud?
}
