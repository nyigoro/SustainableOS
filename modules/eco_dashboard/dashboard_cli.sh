#!/bin/bash
# Eco-Dashboard v0.1 - CLI TUI for SustainableOS
# Displays RAM, frozen/active processes, reaper stats

set -e

LOG_FILE="/tmp/s_os_pressure.log"
REAP_LOG="/tmp/s_os_reap_count.log"
[ ! -f "$REAP_LOG" ] && echo 0 > "$REAP_LOG"

# ANSI colors
GREEN="\e[32m"
YELLOW="\e[33m"
RED="\e[31m"
RESET="\e[0m"

draw_bar() {
    local percent=$1
    local width=40
    local filled=$((percent * width / 100))
    local empty=$((width - filled))
    local color=$GREEN

    if [ $percent -lt 15 ]; then color=$RED
    elif [ $percent -lt 40 ]; then color=$YELLOW
    fi

    printf "${color}["
    for ((i=0;i<filled;i++)); do printf "="; done
    for ((i=0;i<empty;i++)); do printf " "; done
    printf "] ${percent}%%${RESET}\n"
}

while true; do
    clear
    echo "🌿 SustainableOS Eco-Dashboard (v0.1)"
    echo "----------------------------------------"

    # RAM
    FREE=$(awk '/MemAvailable/ {print $2}' /proc/meminfo)
    TOTAL=$(awk '/MemTotal/ {print $2}' /proc/meminfo)
    PERCENT=$(( FREE * 100 / TOTAL ))
    echo "💾 RAM Available:"
    draw_bar $PERCENT

    # Frozen processes (S)
    FROZEN=$(ps -eo stat | grep -c "^T")
    echo "❄️ Frozen processes: $FROZEN"

    # Active processes (R/S/Z/etc)
    ACTIVE=$(ps -eo stat | grep -c "^[RSDZ]")
    echo "⚡ Active processes: $ACTIVE"

    # Reap count
    REAP_COUNT=$(cat $REAP_LOG)
    echo "🪓 Total Reaps this session: $REAP_COUNT"

    echo "----------------------------------------"
    echo "Press Ctrl+C to exit"
    sleep 1
done
