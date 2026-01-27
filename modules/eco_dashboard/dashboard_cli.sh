#!/bin/bash
# dashboard_cli.sh - Eco-Dashboard TUI (v0.2)
set -e

BASE_DIR="$(dirname "$0")/../sustainability"
LOG_FILE="/tmp/s_os_logs/memory.log"
REAP_LOG="/tmp/s_os_logs/reap_count.log"

# --- Wait for Engine Pulse ---
clear
echo "📡 Waiting for Sustainability Engine to broadcast data..."
until [ -s "$LOG_FILE" ] && [ $(grep -c "MEM_AVAILABLE" "$LOG_FILE") -gt 0 ]; do
    sleep 1
done

while true; do
    # RAM stats with fallback to prevent Division by Zero
    MEM_TOTAL=$(grep MemTotal /proc/meminfo | awk '{print $2}')
    MEM_AVAILABLE=$(tail -n 20 "$LOG_FILE" | grep MEM_AVAILABLE | tail -n 1 | awk '{print $2}')
    
    if [ -z "$MEM_AVAILABLE" ] || [ "$MEM_TOTAL" -eq 0 ]; then
        sleep 1 && continue
    fi

    MEM_PERCENT=$(( MEM_AVAILABLE * 100 / MEM_TOTAL ))

    # Color-coded bar
    BAR_WIDTH=30
    FILLED=$(( MEM_PERCENT * BAR_WIDTH / 100 ))
    EMPTY=$(( BAR_WIDTH - FILLED ))
    [ "$MEM_PERCENT" -gt 40 ] && COLOR="\e[32m" || COLOR="\e[31m"
    
    # Display
    clear
    echo -e "🌿 SustainableOS v0.2 Dashboard"
    echo -e "RAM Usage: [$(printf '%0.s#' $(seq 1 $FILLED))$(printf '%0.s ' $(seq 1 $EMPTY))] $MEM_PERCENT%"
    echo "----------------------------------------"
    echo "❄️ Frozen: $(ps -eo stat | grep -c "^T") | ⚡ Active: $(ps -eo stat | grep -c "^[RSDZ]")"
    echo "🪓 Total Reaps: $(cat $REAP_LOG 2>/dev/null || echo 0)"
    echo "----------------------------------------"
    echo "[E] Toggle Eco Mode | [Q] Quit"

    read -t 1 -n 1 key
    [[ $key == "e" ]] && bash "$BASE_DIR/hal.sh" eco_mode_on
    [[ $key == "q" ]] && exit 0
done