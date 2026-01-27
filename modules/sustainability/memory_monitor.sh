#!/bin/bash
# memory_monitor.sh — SustainableOS v0.2
set -e

BASE_DIR="$(dirname "$0")"
LOG_DIR="/tmp/s_os_logs"
LOG_FILE="$LOG_DIR/memory.log"
REAP_COUNT_FILE="$LOG_DIR/reap_count.log"

MONITOR_INTERVAL=${MONITOR_INTERVAL:-2}
MEMORY_THRESHOLD_PERCENT=${MEMORY_THRESHOLD_PERCENT:-15}

mkdir -p "$LOG_DIR"
echo 0 > "$REAP_COUNT_FILE"

MEM_TOTAL=$(grep MemTotal /proc/meminfo | awk '{print $2}')
echo "MEM_TOTAL $MEM_TOTAL" > "$LOG_FILE"

REAPER_RUNNING=0

while true; do
    MEM_AVAILABLE=$(grep MemAvailable /proc/meminfo | awk '{print $2}')
    MEM_PERCENT=$(( MEM_AVAILABLE * 100 / MEM_TOTAL ))

    echo "MEM_AVAILABLE $MEM_AVAILABLE" >> "$LOG_FILE"
    echo "MEM_PERCENT $MEM_PERCENT" >> "$LOG_FILE"

    if [ "$MEM_PERCENT" -lt "$MEMORY_THRESHOLD_PERCENT" ]; then
        if [ "$REAPER_RUNNING" -eq 0 ]; then
            "$BASE_DIR/reaper.sh" &
            REAPER_RUNNING=1
        fi
        "$BASE_DIR/hal.sh" eco_mode_on
    else
        REAPER_RUNNING=0
        "$BASE_DIR/hal.sh" eco_mode_off
    fi

    sleep "$MONITOR_INTERVAL"
done

<<<<<<< HEAD
=======


>>>>>>> 1316ce836c9519eb6063163f43f0c37407ce7746