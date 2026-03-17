#!/usr/bin/env bash

SID="$1"
FOCUSED="$FOCUSED"

# Get window count for current workspace
if [ "$SID" = "$FOCUSED" ]; then
  WINDOW_COUNT=$(/opt/homebrew/bin/aerospace list-windows --workspace "$SID" | wc -l | tr -d ' ')
  sketchybar --set "$NAME" \
    background.drawing=on \
    label.color=0xff000000 \
    background.color=0xffffffff \
    label="$SID"
  
  # Update chevron with window count
  sketchybar --set chevron label="($WINDOW_COUNT)"
else
  sketchybar --set "$NAME" \
    background.drawing=off \
    label.color=0xffffffff \
    label="$SID"
fi

