#!/bin/bash
# freezer.sh - Pause idle apps to save CPU/RAM
set -e

BASE_DIR="$(dirname "$0")"
LOG_FILE="/tmp/s_os_logs/frozen_procs.log"
IDLE_THRESHOLD=${IDLE_THRESHOLD:-60}
DRY_RUN=${DRY_RUN:-1}

echo "🌱 Freezer started..."
mkdir -p "$(dirname "$LOG_FILE")"

while true; do
    IDLE_PROCS=$(ps -eo pid,comm,etimes --no-headers | awk -v t="$IDLE_THRESHOLD" '$3>t {print $1":"$2}')
    
    echo "" > "$LOG_FILE"
    for proc in $IDLE_PROCS; do
        PID=$(echo $proc | cut -d: -f1)
        CMD=$(echo $proc | cut -d: -f2)

        # Skip system & whitelisted processes
        case "$CMD" in
            bash|memory_monitor.sh|reaper.sh|freezer.sh|systemd|zygote|system_server|surfaceflinger)
                continue
                ;;
        esac

        if [ "$DRY_RUN" -eq 1 ]; then
            echo "[Freezer] Would freeze $CMD ($PID)" >> "$LOG_FILE"
        else
            kill -STOP "$PID"
            echo "[Freezer] Frozen $CMD ($PID)" >> "$LOG_FILE"
            # Optional: throttle CPU while freezing
            "$BASE_DIR/hal.sh" eco_cpu_limit 800000
        fi
    done

    sleep 10
done


