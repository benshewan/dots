{
  lib,
  config,
  ...
}: {
  config = lib.mkIf config.night-sky.desktops.hyprland.enable {
    wayland.windowManager.hyprland.settings.windowrulev2 = [
      "float,class:^(pavucontrol)$"
      "float,class:^(file_progress)$"
      "float,class:^(confirm)$"
      "float,class:^(dialog)$"
      "float,class:^(download)$"
      "float,class:^(notification)$"
      "float,class:^(error)$"
      "float,class:^(confirmreset)$"
      "float,title:^(branchdialog)$"
      "float,title:^(Confirm to replace files)$"
      "float,title:^(File Operation Progress)$"
      "float,title:^(About Mozilla Thunderbird)$"

      # XDG Portal
      "float,class:^(Xdg-desktop-portal-gtk)$,title:^(.*)(File)(.*)$"
      "size 800 450,class:^(Xdg-desktop-portal-gtk)$,title:^(.*)(File)(.*)$"
      "stayfocused,class:^(Xdg-desktop-portal-gtk)$,title:^(.*)(File)(.*)$"
      "dimaround,class:^(Xdg-desktop-portal-gtk)$,title:^(.*)(File)(.*)$"
      "center(1),class:^(Xdg-desktop-portal-gtk)$,title:^(.*)(File)(.*)$"

      # Unlock Keyring
      "float,title:^(Unlock Login Keyring)$"
      "stayfocused,title:^(Unlock Login Keyring)$"
      "dimaround,title:^(Unlock Login Keyring)$"

      # Wifi Settings
      "float,title:^(nm-tray)$"
      "stayfocused,title:^(nm-tray)$"
      "move onscreen cursor 0 5,title:^(nm-tray)$"

      # Firefox Start
      # ------------------------------------------------------------------------------------------------------------------------
      "idleinhibit fullscreen, class:^(firefox|zen)$"
      "suppressevent maximize, class:^(firefox|zen)$"
      # PIP
      "float, class:^(firefox|zen)$,title:^(Picture-in-Picture)$"
      "size 600 338, class:^(firefox|zen)$,title:(Picture-in-Picture)"
      "pin, class:^(firefox|zen)$,title:^(Picture-in-Picture)$"
      "suppressevent maximize, class:^(firefox|zen)$,title:^(Picture-in-Picture)$"
      "suppressevent fullscreen, class:^(firefox|zen)$,title:^(Picture-in-Picture)$"
      "move onscreen 100%-w-15 5%, class:^(firefox|zen)$,title:^(Picture-in-Picture)$"
      "noanim on, class:^(firefox|zen)$,title:^(Picture-in-Picture)$"
      "noinitialfocus, class:^(firefox|zen)$,title:^(Picture-in-Picture)$"

      # Dialogs
      "float,class:^(firefox)$,title:^(File Upload)$"
      "center(1),class:^(firefox)$,title:^(File Upload)$"
      "stayfocused,class:^(firefox)$,title:^(File Upload)$"
      "dimaround,class:^(firefox)$,title:^(File Upload)$"
      "size 800 450,class:^(firefox)$,title:^(File Upload)$"

      "float,class:^(firefox)$,title:^(Opening)(.*)$"
      "suppressevent fullscreen,class:^(firefox)$,title:^(Opening)(.*)$"
      "fullscreenstate 0 2,class:^(firefox)$,title:^(Opening)(.*)$"
      "center(1),class:^(firefox)$,title:^(Opening)(.*)$"
      "stayfocused,class:^(firefox)$,title:^(Opening)(.*)$"
      "dimaround,class:^(firefox)$,title:^(Opening)(.*)$"
      "size 800 450,class:^(firefox)$,title:^(Opening)(.*)$"

      "suppressevent maximize, class:^(firefox)$,title:^()$"
      "suppressevent fullscreen, class:^(firefox)$,title:^()$"
      "float, class:^(firefox)$,title:^()$"

      "float,title:^(Save As)$"
      "size 800 450,title:^(Save As)$"
      "stayfocused,title:^(Save As)$"
      "dimaround,title:^(Save As)$"
      "center(1),title:^(Save As)$"

      # Firefox End
      # ------------------------------------------------------------------------------------------------------------------------

      # KDEConnect
      # "float, class:^(firefox)$,title:^(Mozilla Firefox)$"
      # "move onscreen cursor, class:^(firefox)$,title:^(Mozilla Firefox)$"
      # "float, class:^(firefox)$,title:^(Send File - Mozilla Firefox)$"
      # "center(1), class:^(firefox)$,title:^(Send File - Mozilla Firefox)$"

      # Dolphin Start
      # ------------------------------------------------------------------------------------------------------------------------

      # "float,title:^(New Folder — Dolphin)$"
      # "size 800 450,title:^(New Folder — Dolphin)$"
      "stayfocused,title:^(New Folder — Dolphin)$"
      "dimaround,title:^(New Folder — Dolphin)$"
      "center(1),title:^(New Folder — Dolphin)$"

      "stayfocused,class:^(kiod5)$,title:^(Authentication Dialog)$"
      "dimaround,class:^(kiod5)$,title:^(Authentication Dialog)$"
      "center(1),class:^(kiod5)$,title:^(Authentication Dialog)$"

      # Dolphin End
      # ------------------------------------------------------------------------------------------------------------------------

      # Vscode
      "fullscreenstate 0 2, class:^(code-url-handler)$"

      # Satty
      "float,class:^(com.gabm.satty)$"

      # Polkit Request
      "float,class:^(polkit-gnome)(.*)$"
      "dimaround,class:^(polkit-gnome)(.*)$"
      "stayfocused,class:^(polkit-gnome)(.*)$"

      # Android Studio
      "float,class:^(Emulator)$"

      # Wisenet Viewer
      "suppressevent fullscreen, title:^(Wisenet Viewer)$"
      "suppressevent maximize, title:^(Wisenet Viewer)$"

      # XWayland Stuff
      # ------------------------------------------------------------------------------------------------------------------------

      "opacity 0.0 override, class:^(xwaylandvideobridge)$"
      "noanim, class:^(xwaylandvideobridge)$"
      "noinitialfocus, class:^(xwaylandvideobridge)$"
      "maxsize 1 1, class:^(xwaylandvideobridge)$"
      "noblur, class:^(xwaylandvideobridge)$"
      "nofocus, class:^(xwaylandvideobridge)$"

      # ------------------------------------------------------------------------------------------------------------------------
    ];
  };
}
