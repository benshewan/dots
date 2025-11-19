{
  lib,
  config,
  ...
}: {
  config = lib.mkIf config.night-sky.desktops.hyprland.enable {
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
      "idle_inhibit fullscreen, match:class ^(firefox.*|zen)$"
      "suppress_event maximize, match:class ^(firefox.*|zen)$"
      # PIP
      "match:title ^(Picture-in-Picture)$, float true, match:class ^(firefox.*|zen)$"
      "match:title (Picture-in-Picture), size 600 338, match:class ^(firefox.*|zen)$"
      "match:title ^(Picture-in-Picture)$, pin true, match:class ^(firefox.*|zen)$"
      "match:title ^(Picture-in-Picture)$, suppress_event maximize, match:class ^(firefox.*|zen)$"
      "match:title ^(Picture-in-Picture)$, suppress_event fullscreen, match:class ^(firefox.*|zen)$"
      "match:title ^(Picture-in-Picture)$, move onscreen 100%-w-15 5%, match:class ^(firefox.*|zen)$"
      "match:title ^(Picture-in-Picture)$, no_anim on, match:class ^(firefox.*|zen)$"
      "match:title ^(Picture-in-Picture)$, no_initial_focus true, match:class ^(firefox.*|zen)$"

      # Dialogs
      "match:class ^(firefox)$,match:title ^(File Upload)$, float true"
      "match:class ^(firefox)$,match:title ^(File Upload)$, center true"
      "match:class ^(firefox)$,match:title ^(File Upload)$, stay_focused true"
      "match:class ^(firefox)$,match:title ^(File Upload)$, dim_around true"
      "match:class ^(firefox)$,match:title ^(File Upload)$, size 800 450"

      "match:class ^(firefox)$,match:title ^(Opening)(.*)$, float true"
      "match:class ^(firefox)$,match:title ^(Opening)(.*)$, suppress_event fullscreen"
      "match:class ^(firefox)$,match:title ^(Opening)(.*)$, fullscreen_state 0 2"
      "match:class ^(firefox)$,match:title ^(Opening)(.*)$, center true"
      "match:class ^(firefox)$,match:title ^(Opening)(.*)$, stay_focused true"
      "match:class ^(firefox)$,match:title ^(Opening)(.*)$, dim_around true"
      "match:class ^(firefox)$,match:title ^(Opening)(.*)$, size 800 450"

      "match:title ^()$, suppress_event maximize, match:class ^(firefox)$"
      "match:title ^()$, suppress_event fullscreen, match:class ^(firefox)$"
      "match:title ^()$, float true, match:class ^(firefox)$"

      "match:title ^(Save As)$, float true"
      "match:title ^(Save As)$, size 800 450"
      "match:title ^(Save As)$, stay_focused true"
      "match:title ^(Save As)$, dim_around true"
      "match:title ^(Save As)$, center true"

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
