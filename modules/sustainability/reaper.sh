#!/system/bin/sh
# SustainableOS Reaper v0.1
# Logic: Monitor MemAvailable and cull non-essential background tasks.

THRESHOLD=153600 # 150MB in KB
WHITELIST="/data/local/tmp/s_os_whitelist.txt"
LOG_FILE="/data/local/tmp/reaper_log.txt"

echo "[$(date)] Reaper Service Started" >> $LOG_FILE

while true; do
    # 1. Check Available Memory
    MEM_FREE=$(grep MemAvailable /proc/meminfo | awk '{print $2}')

    if [ "$MEM_FREE" -lt "$THRESHOLD" ]; then
        echo "[$(date)] RAM Critical: ${MEM_FREE}KB. Initiating Harvest..." >> $LOG_FILE
        
        # 2. Find the hungriest background process (excluding system/whitelist)
        # Simplified for v0.1: Targets the oldest non-essential cached process
        TARGET_PID=$(ps -A -o PID,NAME | grep -vE "system_server|com.android.systemui|launcher" | tail -n 1 | awk '{print $1}')

        if [ ! -z "$TARGET_PID" ]; then
            echo "[$(date)] Reaping PID: $TARGET_PID to stabilize system." >> $LOG_FILE
            kill -9 $TARGET_PID
        fi
    fi

    sleep 10 # Check every 10 seconds
done
