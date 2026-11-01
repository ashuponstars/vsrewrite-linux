#!/bin/sh
# UNTESTED. waybar toggles its visibility on SIGUSR1, so this only works if the bar is currently showing.
# save as hide-bar.sh next to run.sh
pkill -SIGUSR1 waybar
