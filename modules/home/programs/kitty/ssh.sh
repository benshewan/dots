#!/usr/bin/env bash
if [[ $TERM == "xterm-kitty" ]];
    then kitty +kitten ssh $@
    else ssh $@ 
fi 