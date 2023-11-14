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
    "float,title:^(Picture-in-Picture)$"
    "pin,title:^(Picture-in-Picture)$"
    # Not really working
    "float,title:^(Extension: \(Bitwarden - Free Password Manager\).*)$"
    "stayfocused,title:^(Extension: \(Bitwarden - Free Password Manager\).*)$"

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
