#!/usr/bin/env bash
state=$(bluetoothctl show | awk '$1=="PowerState:" {print $2}')
if  [ "$state" == "off-blocked" ] ; then
        rfkill unblock 0
    else
        rfkill block 0
fi