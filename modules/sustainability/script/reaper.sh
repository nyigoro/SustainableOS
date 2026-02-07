#!/system/bin/sh
# =====================================================
# reaper.sh — SustainableOS v0.4 (Smart Governor)
# =====================================================

THRESHOLD=153600   # 150MB
LOG_DIR="/tmp/s_os_logs"
REAP_COUNT="$LOG_DIR/reap_count.log"

BASE_WHITELIST="/system/etc/sustainableos/whitelist.txt"
OEM_WHITELIST="/system/etc/sustainableos/whitelist_oem.txt"

mkdir -p "$LOG_DIR"

MANUFACTURER="$(getprop ro.product.manufacturer | tr 'A-Z' 'a-z')"

# Load OEM whitelist if exists
if [ -f "$OEM_WHITELIST" ]; then
  WHITELIST="$OEM_WHITELIST"
else
  WHITELIST="$BASE_WHITELIST"
fi

log() {
  echo "[Reaper][$MANUFACTURER] $1" >> "$LOG_DIR/reaper.log"
}

is_whitelisted() {
  grep -Fxq "$1" "$WHITELIST" 2>/dev/null
}

# -----------------------------------------------------
# Get foreground app
# -----------------------------------------------------
get_foreground_pkg() {
  dumpsys window windows | grep -E 'mCurrentFocus|mFocusedApp' \
    | sed -n 's/.* \([a-zA-Z0-9._]*\)\/.*/\1/p' \
    | head -n 1
}

# -----------------------------------------------------
# Get process oom_score_adj
# -----------------------------------------------------
get_oom_adj() {
  local pid=$1
  if [ -f "/proc/$pid/oom_score_adj" ]; then
    cat "/proc/$pid/oom_score_adj"
  else
    echo 0
  fi
}

# -----------------------------------------------------
# Main loop
# -----------------------------------------------------
while true; do
  MEM_FREE=$(awk '/MemAvailable/ {print $2}' /proc/meminfo)

  if [ "$MEM_FREE" -lt "$THRESHOLD" ]; then
    FG_APP="$(get_foreground_pkg)"

    # Iterate top RAM consumers
    ps -A -o pid,rss,args --sort=-rss | while read PID RSS CMD; do
      PKG=$(echo "$CMD" | cut -d':' -f1)
      [ -z "$PID" ] && continue

      # Core system protections
      case "$PKG" in
        system_server|zygote*|surfaceflinger|audioserver|mediaserver|init|logd)
          continue
          ;;
      esac

      # Skip foreground app
      [ "$PKG" = "$FG_APP" ] && continue

      # Skip whitelist
      is_whitelisted "$PKG" && continue

      # Skip critical low-memory processes
      OOM_ADJ=$(get_oom_adj "$PID")
      [ "$OOM_ADJ" -le -900 ] && continue

      # Attempt graceful kill first
      kill -15 "$PID" 2>/dev/null
      sleep 1

      # Force kill if still alive
      kill -9 "$PID" 2>/dev/null

      # Increment counter
      COUNT=$(cat "$REAP_COUNT" 2>/dev/null || echo 0)
      echo $((COUNT + 1)) > "$REAP_COUNT"

      log "Reaped $PKG (PID $PID, RSS ${RSS}K, FG=$FG_APP, OOM=$OOM_ADJ)"
      break
    done
  fi

  sleep 10
done
