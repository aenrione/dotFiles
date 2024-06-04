#!/bin/sh
xrandr --output eDP --off --output HDMI-A-0 --off --output DP-1-0 --off --output DP-1-1 --off
xrandr --output eDP --primary --mode 2560x1440 --pos 1055x1080  --scale 0.6x0.6 --rotate normal --output HDMI-A-0 --mode 1920x1080 --pos 0x0 --rotate normal --output DP-1-0 --off --output DP-1-1 --off
