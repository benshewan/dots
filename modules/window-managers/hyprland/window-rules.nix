{...}: {
  # Home Manager
  # --------------------------------------------------------------------------------
  flake.modules.homeManager."window-managers/hyprland" = {
    pkgs,
    lib,
    config,
    ...
  }: {
    wayland.windowManager.hyprland.settings.windowrule = [
      "match:class ^(pavucontrol)$, float true"
      "match:class ^(file_progress)$, float true"
      "match:class ^(confirm)$, float true"
      "match:class ^(dialog)$, float true"
      "match:class ^(download)$, float true"
      "match:class ^(notification)$, float true"
      "match:class ^(error)$, float true"
      "match:class ^(confirmreset)$, float true"
      "match:title ^(branchdialog)$, float true"
      "match:title ^(Confirm to replace files)$, float true"
      "match:title ^(File Operation Progress)$, float true"
      "match:title ^(About Mozilla Thunderbird)$, float true"

      # XDG Portal
      "match:class ^(Xdg-desktop-portal-gtk)$,match:title ^(.*)(File)(.*)$, float true"
      "match:class ^(Xdg-desktop-portal-gtk)$,match:title ^(.*)(File)(.*)$, size 800 450"
      "match:class ^(Xdg-desktop-portal-gtk)$,match:title ^(.*)(File)(.*)$, stay_focused true"
      "match:class ^(Xdg-desktop-portal-gtk)$,match:title ^(.*)(File)(.*)$, dim_around true"
      "match:class ^(Xdg-desktop-portal-gtk)$,match:title ^(.*)(File)(.*)$, center true"

      # Unlock Keyring
      "match:title ^(Unlock Login Keyring)$, float true"
      "match:title ^(Unlock Login Keyring)$, stay_focused true"
      "match:title ^(Unlock Login Keyring)$, dim_around true"

      # Wifi Settings
      "match:title ^(nm-tray)$, float true"
      "match:title ^(nm-tray)$, stay_focused true"
      "match:title ^(nm-tray)$, move onscreen cursor 0 5"

      # Firefox Start
      # ------------------------------------------------------------------------------------------------------------------------
      "match:class ^(firefox.*|zen)$, idle_inhibit fullscreen, suppress_event maximize"

      {
        name = "Firefox PIP";
        "match:title" = "^(Picture-in-Picture)$";
        "match:class" = "^(firefox.*|zen)$";
        float = true;
        size = "600 338";
        pin = true;
        suppress_event = "maximize fullscreen";
        move = "(monitor_w-window_w-15) ((monitor_h-window_h)*0.05)";
        no_anim = true;
        no_initial_focus = true;
      }

      # Dialogs
      "match:class ^(firefox.*|zen)$, match:title ^(File Upload)$, float true, center true, stay_focused true, dim_around true, size 800 450"

      "match:class ^(firefox.*|zen)$, match:title ^(Opening)(.*)$, float true, suppress_event fullscreen, fullscreen_state 0 2, center true, stay_focused true, dim_around true, size 800 450"

      "match:class ^(firefox.*|zen)$, match:title ^()$, suppress_event maximize fullscreen, float true"

      "match:title ^(Save As)$, float true, size 800 450, stay_focused true, dim_around true, center true"

      # Firefox End
      # ------------------------------------------------------------------------------------------------------------------------

      # KDEConnect
      # "match:title ^(Mozilla Firefox)$, float true, match:class ^(firefox)$"
      # "match:title ^(Mozilla Firefox)$, move onscreen cursor, match:class ^(firefox)$"
      # "match:title ^(Send File - Mozilla Firefox)$, float true, match:class ^(firefox)$"
      # "match:title ^(Send File - Mozilla Firefox)$, center true, match:class ^(firefox)$"

      # Dolphin Start
      # ------------------------------------------------------------------------------------------------------------------------

      # "match:title ^(New Folder — Dolphin)$, float true"
      # "match:title ^(New Folder — Dolphin)$, size 800 450"
      "match:title ^(New Folder — Dolphin)$, stay_focused true"
      "match:title ^(New Folder — Dolphin)$, dim_around true"
      "match:title ^(New Folder — Dolphin)$, center true"

      "match:class ^(kiod5)$,match:title ^(Authentication Dialog)$, stay_focused true"
      "match:class ^(kiod5)$,match:title ^(Authentication Dialog)$, dim_around true"
      "match:class ^(kiod5)$,match:title ^(Authentication Dialog)$, center true"

      # Dolphin End
      # ------------------------------------------------------------------------------------------------------------------------

      # Vscode
      "fullscreen_state 0 2, match:class ^(code-url-handler)$"

      # MongoDB Compass
      "match:class ^(mongodb-compass)$,match:title ^(Select JSON or CSV to import|Target output file)$, float true, center true, dim_around true,max_size monitor_w (monitor_h/1.2)"

      # Satty
      "match:class ^(com.gabm.satty)$, float true"

      # Polkit Request
      "match:class ^(polkit-gnome)(.*)$, float true"
      "match:class ^(polkit-gnome)(.*)$, dim_around true"
      "match:class ^(polkit-gnome)(.*)$, stay_focused true"

      # Android Studio
      "match:class ^(Emulator)$, float true"

      # Wisenet Viewer
      "suppress_event fullscreen, match:title ^(Wisenet Viewer)$"
      "suppress_event maximize, match:title ^(Wisenet Viewer)$"

      # Libreoffice
      {
        name = "LibreOffice focus import";
        "match:title" = "^(Text Import - \\[.*)$";
        "match:class" = "^(soffice)$";
        float = true;
        size = "800 800";
        center = true;
        stay_focused = true;
        dim_around = true;
      }
      # XWayland Stuff
      # ------------------------------------------------------------------------------------------------------------------------

      # "opacity 0.0 override, match:class ^(xwaylandvideobridge)$"
      # "no_anim, match:class ^(xwaylandvideobridge)$"
      # "no_initial_focus, match:class ^(xwaylandvideobridge)$"
      # "maxsize 1 1, match:class ^(xwaylandvideobridge)$"
      # "noblur, match:class ^(xwaylandvideobridge)$"
      # "nofocus, match:class ^(xwaylandvideobridge)$"

      # ------------------------------------------------------------------------------------------------------------------------
    ];
  };
}
