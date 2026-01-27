#!/system/bin/sh
# reaper.sh — SustainableOS v0.2

THRESHOLD=153600          # 150MB available threshold
LOG_DIR="/tmp/s_os_logs"
REAP_COUNT="$LOG_DIR/reap_count.log"
WHITELIST="/system/etc/sustainableos/whitelist.txt"

mkdir -p "$LOG_DIR"

is_whitelisted() {
  grep -Fxq "$1" "$WHITELIST" 2>/dev/null
}

while true; do
  MEM_FREE=$(grep MemAvailable /proc/meminfo | awk '{print $2}')

  if [ "$MEM_FREE" -lt "$THRESHOLD" ]; then
    # Pick the top RAM consumer (excluding system)
    TARGET=$(ps -A -o pid,comm,rss --sort=-rss | awk '
      NR>1 {
        if ($2 ~ /system_server|zygote|surfaceflinger|audioserver|mediaserver|init|logd/) next
        print $1 " " $2 " " $3
      }' | head -n 1)

    PID=$(echo "$TARGET" | awk '{print $1}')
    COMM=$(echo "$TARGET" | awk '{print $2}')

    if [ -n "$PID" ] && ! is_whitelisted "$COMM"; then
      kill -9 "$PID" 2>/dev/null || true

      COUNT=$(cat "$REAP_COUNT" 2>/dev/null || echo 0)
      echo $((COUNT + 1)) > "$REAP_COUNT"

      echo "[Reaper] Killed $COMM ($PID)" >> "$LOG_DIR/reaper.log"
    fi
  fi

  sleep 10
done
