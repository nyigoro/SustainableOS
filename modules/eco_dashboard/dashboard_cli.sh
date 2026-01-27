#!/bin/bash
# dashboard_cli.sh — SustainableOS v0.2

BASE_DIR="$(dirname "$0")/../sustainability"
LOG_FILE="/tmp/s_os_logs/memory.log"
REAP_LOG="/tmp/s_os_logs/reap_count.log"

clear
echo "📡 Waiting for Sustainability Engine..."
until [ -s "$LOG_FILE" ] && grep -q MEM_AVAILABLE "$LOG_FILE"; do
    sleep 1
done
while true; do
    MEM_TOTAL=$(grep MEM_TOTAL "$LOG_FILE" | awk '{print $2}')
    MEM_AVAILABLE=$(grep MEM_AVAILABLE "$LOG_FILE" | tail -n1 | awk '{print $2}')

    [ -z "$MEM_TOTAL" ] || [ -z "$MEM_AVAILABLE" ] && sleep 1 && continue

    MEM_PERCENT=$(( MEM_AVAILABLE * 100 / MEM_TOTAL ))

    FILLED=$(( MEM_PERCENT * BAR_WIDTH / 100 ))
    EMPTY=$(( BAR_WIDTH - FILLED ))
    clear

done

