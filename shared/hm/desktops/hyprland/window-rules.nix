{...}: {
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
    # PIP
    "float, class:^(firefox)$,title:^(Picture-in-Picture)$"
    "size 800 450, class:^(firefox)$,title:(Picture-in-Picture)"
    "pin, class:^(firefox)$,title:^(Picture-in-Picture)$"
    "nomaximizerequest, class:^(firefox)$,title:^(Picture-in-Picture)$"
    "nofullscreenrequest, class:^(firefox)$,title:^(Picture-in-Picture)$"
    "float, class:^(firefox)$,title:^(Firefox)$ "
    "size 800 450, class:^(firefox)$,title:^(Firefox)$"
    "pin, class:^(firefox)$,title:^(Firefox)$"
    "nomaximizerequest, class:^(firefox)$,title:^(Firefox)$"
    "nofullscreenrequest, class:^(firefox)$,title:^(Firefox)$"

    # Dialogs
    "float,class:^(firefox)$,title:^(File Upload)$"
    "center(1),class:^(firefox)$,title:^(File Upload)$"
    "stayfocused,class:^(firefox)$,title:^(File Upload)$"
    "dimaround,class:^(firefox)$,title:^(File Upload)$"
    "size 800 450,class:^(firefox)$,title:^(File Upload)$"

    "center(1),class:^(firefox)$,title:^(Opening)(.*)$"
    "stayfocused,class:^(firefox)$,title:^(Opening)(.*)$"
    "dimaround,class:^(firefox)$,title:^(Opening)(.*)$"
    "size 800 450,class:^(firefox)$,title:^(Opening)(.*)$"

    "nomaximizerequest, class:^(firefox)$,title:^()$"
    "nofullscreenrequest, class:^(firefox)$,title:^()$"
    "float, class:^(firefox)$,title:^()$"

    "float,title:^(Save As)$"
    "size 800 450,title:^(Save As)$"
    "stayfocused,title:^(Save As)$"
    "dimaround,title:^(Save As)$"
    "center(1),title:^(Save As)$"

    # KDEConnect
    "float, class:^(firefox)$,title:^(Mozilla Firefox)$"
    "move onscreen cursor, class:^(firefox)$,title:^(Mozilla Firefox)$"
    "float, class:^(firefox)$,title:^(Send File - Mozilla Firefox)$"
    "center(1), class:^(firefox)$,title:^(Send File - Mozilla Firefox)$"

    # Vscode
    "fakefullscreen, class:^(code-url-handler)$"

    # Webstorm
    "stayfocused, class:^(jetbrains-webstorm)$,title:^()$,floating:1"
    "center(1), class:^(jetbrains-webstorm)$,title:^()$,floating:1"
    "nofocus,class:^(jetbrains-webstorm)$,title:^(win)(.*)$"
    "center(1), class:^(jetbrains-webstorm)$,title:^(splash)$"
    "nofocus,class:^(jetbrains-webstorm)$,title:^(splash)$"
    "dimaround, class:^(jetbrains-webstorm)$,title:^(Settings)$"
    # "nofocus,class:^(jetbrains-webstorm)$,title:^(win45)$"
    # "nofocus,class:^(jetbrains-webstorm)$,title:^(win29)$"

    # "stayfocused, class:^(jetbrains-webstorm)$,title:^(Settings)$,floating:1"
    # "center(1), class:^(jetbrains-webstorm)$,title:^(Settings)$,floating:1"

    # Polkit Request
    "float,title:^(Authentication Required)(.*)$"
    "dimaround,title:^(Authentication Required)(.*)$"
    "stayfocused,title:^(Authentication Required)(.*)$"

    "float,title:^(mpv)$"
    "opacity 0.0 override 0.0 override,class:^(xwaylandvideobridge)$"
    "noanim,class:^(xwaylandvideobridge)$"
    "nofocus,class:^(xwaylandvideobridge)$"
    "noinitialfocus,class:^(xwaylandvideobridge)$"
  ];
}
