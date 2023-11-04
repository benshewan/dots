#!/usr/bin/env bash
LID_STATE=$(cat /proc/acpi/button/lid/LID0/state | cut -d':' -f2 | tr -d ' ')

case ${LID_STATE} in
    closed)
    echo closed
    exit 1
    ;;
    open*)
    echo open
    exit 0
    ;;
    *)
    # LID is open by default
    echo unknown
    exit 0
    ;;
esac