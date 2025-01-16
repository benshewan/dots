#!/usr/bin/env bash
if [[ $TERM == "xterm-kitty" ]];
    then kitten ssh $@
    else ssh $@ 
fi 