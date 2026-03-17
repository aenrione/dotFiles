#!/usr/bin/env bash

# Get the item name from SketchyBar (defaults to 'cpu' if not set)
ITEM_NAME="${NAME:-cpu}"

cores=$(sysctl -n hw.ncpu)
total=$(ps -A -o %cpu= | awk '{s+=$1} END {printf "%.1f", s}')
usage=$(echo "$total / $cores" | bc -l)
usage_int=$(printf "%.0f" "$usage")
[ "$usage_int" -gt 100 ] && usage_int=100
[ "$usage_int" -lt 0 ] && usage_int=0

sketchybar --set "$ITEM_NAME" label="${usage_int}%"
