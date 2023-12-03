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
    "float,title:^(Open File)$"
    "float,title:^(Save As)$"
    "float,title:^(branchdialog)$"
    "float,title:^(Confirm to replace files)$"
    "float,title:^(File Operation Progress)$"
    "float,title:^(About Mozilla Thunderbird)$"

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
    "pin, class:^(firefox)$,title:^(Picture-in-Picture)$ "
    "float, class:^(firefox)$,title:^(Firefox)$ "
    "size 800 450, class:^(firefox)$,title:^(Firefox)$"
    "pin, class:^(firefox)$,title:^(Firefox)$"
    # Dialogs
    "float,title:^(File Upload)$"
    "center(1),title:^(File Upload)$"
    "stayfocused,title:^(File Upload)$"
    "dimaround,title:^(File Upload)$"

    # Vscode
    "fakefullscreen, class:^(code-url-handler)$"

    # Webstorm
    "stayfocused, class:^(jetbrains-webstorm)$,title:^()$,floating:1"
    "center(1), class:^(jetbrains-webstorm)$,title:^()$,floating:1"

    # "stayfocused, class:^(jetbrains-webstorm)$,title:^(Settings)$,floating:1"
    # "center(1), class:^(jetbrains-webstorm)$,title:^(Settings)$,floating:1"

    # Polkit Request
    "float,title:^(Authentication Required)(.*)$"
    "dimaround,title:^(Authentication Required)(.*)$"
    "stayfocused,title:^(Authentication Required)(.*)$"

    "float,title:^(mpv)$"
    "opacity 1.0 1.0,class:^(wofi)$"
    "opacity 0.0 override 0.0 override,class:^(xwaylandvideobridge)$"
    "noanim,class:^(xwaylandvideobridge)$"
    "nofocus,class:^(xwaylandvideobridge)$"
    "noinitialfocus,class:^(xwaylandvideobridge)$"
  ];
}
