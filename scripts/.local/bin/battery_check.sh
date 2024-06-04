#!/bin/sh

# Check if acpi is installed
if ! command -v acpi &> /dev/null; then
    echo "acpi is not installed. Please install it and try again."
    exit 1
fi

# Get the battery level
battery_level=$(acpi -b | grep -P -o '[0-9]+(?=%)')

# Check if the battery level is less than 15%
if [ "$battery_level" -lt 15 ]; then
    # Send a notification
    notify-send -u critical "Battery Low" "Battery level is ${battery_level}%"

    # Play a sound
    paplay /usr/share/sounds/freedesktop/stereo/alarm-clock-elapsed.oga
fi

