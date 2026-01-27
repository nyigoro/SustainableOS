#!/bin/bash
# memory_monitor.sh - Real-time RAM pressure detection with HAL
set -e

BASE_DIR="$(dirname "$0")"
LOG_FILE="/tmp/s_os_logs/memory.log"
REAP_COUNT_FILE="/tmp/s_os_logs/reap_count.log"

MONITOR_INTERVAL=${MONITOR_INTERVAL:-2}
MEMORY_THRESHOLD_PERCENT=${MEMORY_THRESHOLD_PERCENT:-15}

mkdir -p "$(dirname "$LOG_FILE")"
echo "MEM_TOTAL $(grep MemTotal /proc/meminfo | awk '{print $2}')" > "$LOG_FILE"

while true; do
    AVAILABLE=$(grep MemAvailable /proc/meminfo | awk '{print $2}')
    TOTAL=$(grep MemTotal /proc/meminfo | awk '{print $2}')
    PERCENT=$(( AVAILABLE * 100 / TOTAL ))

    echo "MEM_AVAILABLE $AVAILABLE" >> "$LOG_FILE"
    echo "MEM_PERCENT $PERCENT" >> "$LOG_FILE"

    # Trigger Reaper if below threshold
    if [ "$PERCENT" -lt "$MEMORY_THRESHOLD_PERCENT" ]; then
        "$BASE_DIR/reaper.sh" &
        "$BASE_DIR/hal.sh" eco_mode_on
    else
        "$BASE_DIR/hal.sh" eco_mode_off
    fi

    sleep "$MONITOR_INTERVAL"
done


