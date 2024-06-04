#!/bin/sh
xrandr --output eDP --off --output HDMI-A-0 --off --output DP-1-0 --off --output DP-1-1 --off
xrandr --output eDP --mode 2560x1440 --pos 1920x0 --scale 0.6x0.6  --primary --rotate normal --output HDMI-A-0 --off --output DP-1-0 --mode 1920x1080 --pos 0x0 --rotate normal --output DP-1-1 --off
