#!/system/bin/sh
# reaper.sh — SustainableOS v0.2

THRESHOLD=153600
LOG_DIR="/tmp/s_os_logs"
REAP_COUNT="$LOG_DIR/reap_count.log"

mkdir -p "$LOG_DIR"

MEM_FREE=$(grep MemAvailable /proc/meminfo | awk '{print $2}')

[ "$MEM_FREE" -ge "$THRESHOLD" ] && exit 0

TARGET_PID=$(ps -A -o PID,NAME --no-headers \
  | grep -vE "system_server|surfaceflinger|zygote|launcher|dashboard" \
  | tail -n1 | awk '{print $1}')

if [ -n "$TARGET_PID" ]; then
    kill -9 "$TARGET_PID" 2>/dev/null || true
    COUNT=$(cat "$REAP_COUNT" 2>/dev/null || echo 0)
    echo $((COUNT + 1)) > "$REAP_COUNT"
fi



