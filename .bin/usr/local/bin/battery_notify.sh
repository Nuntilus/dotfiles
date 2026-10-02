#!/usr/bin/env bash
set -euo pipefail

battery_path=/sys/class/power_supply/BAT0
if [[ ! -r "$battery_path/capacity" ]]; then
    for candidate in /sys/class/power_supply/BAT*/capacity; do
        if [[ -r "$candidate" ]]; then
            battery_path=${candidate%/capacity}
            break
        fi
    done
fi

capacity_file=$battery_path/capacity
status_file=$battery_path/status
state_file="${XDG_RUNTIME_DIR:-/tmp}/battery-low-notified"

if [[ ! -r "$capacity_file" ]]; then
    exit 0
fi

capacity=$(<"$capacity_file")
status=$(<"$status_file")

if ((capacity > 20)) || [[ "$status" == "Charging" || "$status" == "Full" ]]; then
    rm -f "$state_file"
    exit 0
fi

if [[ -e "$state_file" ]]; then
    exit 0
fi

notify-send "Battery Low" "Battery at ${capacity}%!" --urgency=critical
touch "$state_file"
