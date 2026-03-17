#!/usr/bin/env bash

# Get the item name from SketchyBar (defaults to 'wifi' if not set)
ITEM_NAME="${NAME:-wifi}"

iface=$(networksetup -listallhardwareports | awk '/Wi-Fi/{getline; print $2}')
[ -z "$iface" ] && iface="en0"

# Store previous values in temp file
CACHE_FILE="/tmp/sketchybar_wifi_${iface}"

# Read previous values
if [ -f "$CACHE_FILE" ]; then
  read -r rx1 tx1 < "$CACHE_FILE"
else
  rx1=0
  tx1=0
fi

# Get current values
rx2=$(netstat -ibn | awk -v iface="$iface" '$1==iface {print $7; exit}')
tx2=$(netstat -ibn | awk -v iface="$iface" '$1==iface {print $10; exit}')

# Calculate differences (per second based on update_freq)
drx=$((rx2 - rx1))
dtx=$((tx2 - tx1))

# Store current values for next iteration
echo "$rx2 $tx2" > "$CACHE_FILE"

format_speed() {
  local speed=$1
  [ "$speed" -lt 0 ] && speed=0  # Handle negative values on first run
  if [ "$speed" -gt 1000000 ]; then 
    printf "%.1f MB/s" "$(echo "$speed/1000000" | bc -l)"
  else 
    printf "%.0f KB/s" "$(echo "$speed/1000" | bc -l)"
  fi
}

sketchybar --set "$ITEM_NAME" icon="󰁅" label="$(format_speed $drx) ↓ $(format_speed $dtx) ↑"
