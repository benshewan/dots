#!/usr/bin/env bash
# KDE Connect's clipbard share doesn't seem to work in wayland apps in hyprland, so I made this to do it manually
# simply run with "wl-paste --type text --watch ./share-clipboard" to share your clipboard again!
CLIPBOARD_TEXT=$(cliphist list | head -n 1 | cliphist decode)
DEVICE_ID="d1736d72_cf5d_4cde_8688_050b290835d9"

kdeconnect-cli -d $DEVICE_ID --share-text "$CLIPBOARD_TEXT"

