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

      # Firefox
      # ----------
      "idleinhibit fullscreen, class:^(firefox)$"
      # PIP
      "float, class:^(firefox)$,title:^(Picture-in-Picture)$"
      "size 800 450, class:^(firefox)$,title:(Picture-in-Picture)"
      "pin, class:^(firefox)$,title:^(Picture-in-Picture)$"
      "suppressevent maximize, class:^(firefox)$,title:^(Picture-in-Picture)$"
      "suppressevent fullscreen, class:^(firefox)$,title:^(Picture-in-Picture)$"
      "float, class:^(firefox)$,title:^(Firefox)$ "
      "size 800 450, class:^(firefox)$,title:^(Firefox)$"
      "pin, class:^(firefox)$,title:^(Firefox)$"
      "suppressevent maximize, class:^(firefox)$,title:^(Firefox)$"
      "suppressevent fullscreen, class:^(firefox)$,title:^(Firefox)$"

      # Dialogs
      "float,class:^(firefox)$,title:^(File Upload)$"
      "center(1),class:^(firefox)$,title:^(File Upload)$"
      "stayfocused,class:^(firefox)$,title:^(File Upload)$"
      "dimaround,class:^(firefox)$,title:^(File Upload)$"
      "size 800 450,class:^(firefox)$,title:^(File Upload)$"

      "float,class:^(firefox)$,title:^(Opening)(.*)$"
      "suppressevent fullscreen,class:^(firefox)$,title:^(Opening)(.*)$"
      "fakefullscreen,class:^(firefox)$,title:^(Opening)(.*)$"
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

      # ----------

      # KDEConnect
      # "float, class:^(firefox)$,title:^(Mozilla Firefox)$"
      # "move onscreen cursor, class:^(firefox)$,title:^(Mozilla Firefox)$"
      # "float, class:^(firefox)$,title:^(Send File - Mozilla Firefox)$"
      # "center(1), class:^(firefox)$,title:^(Send File - Mozilla Firefox)$"

      # Dolphin
      # "float,title:^(New Folder — Dolphin)$"
      # "size 800 450,title:^(New Folder — Dolphin)$"
      "stayfocused,title:^(New Folder — Dolphin)$"
      "dimaround,title:^(New Folder — Dolphin)$"
      "center(1),title:^(New Folder — Dolphin)$"

      "stayfocused,class:^(kiod5)$,title:^(Authentication Dialog)$"
      "dimaround,class:^(kiod5)$,title:^(Authentication Dialog)$"
      "center(1),class:^(kiod5)$,title:^(Authentication Dialog)$"

      # Vscode
      "fakefullscreen, class:^(code-url-handler)$"

      # Webstorm
      # ----------
      # # UI elements
      # "nofocus,class:^(jetbrains-webstorm)$,title:^(win)(.*)$"

      # # search
      # "stayfocused, class:^(jetbrains-webstorm)$,title:^()$"
      # "center(1), class:^(jetbrains-webstorm)$,title:^()$"
      # "center(1), class:^(jetbrains-webstorm)$,title:^(win3)$"
      # "stayfocused, class:^(jetbrains-webstorm)$,title:^(win3)$"

      # # splash
      # "center(1), class:^(jetbrains-webstorm)$,title:^(splash)$"
      # "nofocus,class:^(jetbrains-webstorm)$,title:^(splash)$"

      # # Settings
      # "dimaround, class:^(jetbrains-webstorm)$,title:^(Settings)$"
      # "stayfocused, class:^(jetbrains-webstorm)$,title:^(Settings)$,floating:1"
      # "center(1), class:^(jetbrains-webstorm)$,title:^(Settings)$,floating:1"

      # # Open Project
      # "dimaround, class:^(jetbrains-webstorm)$,title:^(Open Project)$"
      # "stayfocused, class:^(jetbrains-webstorm)$,title:^(Open Project)$,floating:1"
      # "center(1), class:^(jetbrains-webstorm)$,title:^(Open Project)$,floating:1"
      # ----------

      # Polkit Request
      "float,class:^(polkit-gnome)(.*)$"
      "dimaround,class:^(polkit-gnome)(.*)$"
      "stayfocused,class:^(polkit-gnome)(.*)$"

      # XWayland stuff
      "opacity 0.0 override 0.0 override,class:^(xwaylandvideobridge)$"
      "noanim,class:^(xwaylandvideobridge)$"
      "nofocus,class:^(xwaylandvideobridge)$"
      "noinitialfocus,class:^(xwaylandvideobridge)$"
    ];
  };
}
