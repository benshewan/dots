{
  inputs,
  pkgs,
  config,
  lib,
  ...
}: let
  cfg = config.night-sky.desktops.kde;
in {
  options.night-sky.desktops.kde = {
    enable = lib.mkEnableOption "kde";
  };

  imports = [inputs.plasma-manager.homeModules.plasma-manager];

  config = lib.mkIf cfg.enable {
    # Enables support for KDE Configuration
    home.packages = with pkgs; [
      # Styles
      lightly-qt
      # Extensions
      # libsForQt5.bismuth
    ];

    programs.plasma = {
      enable = true;

      # set dolphin click settings
      workspace.clickItemTo = "select";

      # hotkeys.commands."Launch Konsole" = {
      #   key = "Meta+Alt+K";
      #   command = "konsole";
      # };

      # Mouse settings
      configFile.kcminputrc.Mouse.X11LibInputXAccelProfileFlat = true;
      configFile.kwinrc.MouseBindings.CommandAllWheel = "Maximize/Restore";
      configFile.kwinrc.Windows.FocusPolicy = "FocusFollowsMouse";
      # Navis Mouse settings
      configFile.kcminputrc."Libinput.2362.628.PIXA3854:00 093A:0274 Touchpad".NaturalScroll = true;
      configFile.kcminputrc."Libinput.2362.628.PIXA3854:00 093A:0274 Touchpad".TapToClick = true;

      # Some mid-level settings:
      # shortcuts = {
      #   ksmserver = {
      #     "Lock Session" = [ "Screensaver" "Meta+Ctrl+Alt+L" ];
      #   };

      #   kwin = {
      #     "Expose" = "Meta+,";
      #     "Switch Window Down" = "Meta+J";
      #     "Switch Window Left" = "Meta+H";
      #     "Switch Window Right" = "Meta+L";
      #     "Switch Window Up" = "Meta+K";
      #   };
      # };

      # A low-level setting:
      # configFile."kdeglobals"."General"."BrowserApplication" = "firefox.desktop";

      # Colors?
      # "kdeglobals"."WM"."activeBackground" = "30,30,46";
      # "kdeglobals"."WM"."activeBlend" = "205,214,244";
      # "kdeglobals"."WM"."activeForeground" = "205,214,244";
      # "kdeglobals"."WM"."inactiveBackground" = "17,17,27";
      # "kdeglobals"."WM"."inactiveBlend" = "166,173,200";
      # "kdeglobals"."WM"."inactiveForeground" = "166,173,200";
    };
  };
}
