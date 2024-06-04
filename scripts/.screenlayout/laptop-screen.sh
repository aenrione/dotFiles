#!/bin/sh
xrandr --output eDP-1 --off --output HDMI-1 --off --output DP-1-1 --off --output DP-1-1 --off
xrandr --output eDP-1 --primary --mode 2560x1440 --pos 0x0  --scale 0.7x0.7 --rotate normal --output HDMI-1 --off --output DP-1-1 --off --output DP-1-1 --off

