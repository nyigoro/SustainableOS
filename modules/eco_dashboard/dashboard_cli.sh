#!/bin/bash
# dashboard_cli.sh - Eco-Dashboard TUI

BASE_DIR="$(dirname "$0")/../sustainability"
LOG_FILE="/tmp/s_os_logs/memory.log"
REAP_COUNT_FILE="/tmp/s_os_logs/reap_count.log"
FROZEN_LOG="/tmp/s_os_logs/frozen_procs.log"

refresh_interval=1

clear
while true; do
    # RAM stats
    MEM_TOTAL=$(grep MemTotal "$LOG_FILE" | awk '{print $2}')
    MEM_AVAILABLE=$(tail -n1 "$LOG_FILE" | grep MEM_AVAILABLE | awk '{print $2}')
    MEM_PERCENT=$(( MEM_AVAILABLE * 100 / MEM_TOTAL ))

    # Color-coded bar
    BAR_WIDTH=40
    FILLED=$(( MEM_PERCENT * BAR_WIDTH / 100 ))
    EMPTY=$(( BAR_WIDTH - FILLED ))
    if [ "$MEM_PERCENT" -gt 40 ]; then COLOR="\e[32m"; elif [ "$MEM_PERCENT" -ge 15 ]; then COLOR="\e[33m"; else COLOR="\e[31m"; fi
    BAR=$(printf "%0.s█" $(seq 1 $FILLED))$(printf "%0.s " $(seq 1 $EMPTY))

    # Frozen & active processes
    FROZEN=$(ps -eo stat | grep -c "^T")
    ACTIVE=$(ps -eo stat | grep -c "^[RSDZ]")

    # Reap count
    REAPS=$(tail -n1 "$REAP_COUNT_FILE" 2>/dev/null || echo 0)

    # Display dashboard
    clear
    echo -e "🌿 SustainableOS v0.1 Dashboard"
    echo -e "RAM: ${COLOR}${BAR}\e[0m $MEM_PERCENT%"
    echo "Frozen processes: $FROZEN"
    echo "Active processes: $ACTIVE"
    echo "Total Reaps: $REAPS"
    echo "[E] Toggle Eco Mode (CPU/Backlight)"
    echo "[Ctrl+C] Exit"

    # Check for Eco toggle
    read -t "$refresh_interval" -n 1 key
    if [[ $key == "e" ]]; then
        "$BASE_DIR/hal.sh" eco_mode_on
    fi
done
