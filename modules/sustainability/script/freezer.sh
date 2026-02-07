#!/system/bin/sh
# freezer.sh - Pause idle apps to save CPU/RAM
set -e

WHITELIST="/system/etc/sustainableos/whitelist.txt"
LOG_FILE="/tmp/s_os_logs/frozen_procs.log"
IDLE_THRESHOLD=${IDLE_THRESHOLD:-60}
DRY_RUN=${DRY_RUN:-1}

mkdir -p "$(dirname "$LOG_FILE")"
echo "🌱 Freezer started..." >> "$LOG_FILE"

is_whitelisted() {
  grep -Fxq "$1" "$WHITELIST" 2>/dev/null
}

while true; do
  echo "" > "$LOG_FILE"

  # List PIDs
  for pid in $(ls /proc | grep -E '^[0-9]+$'); do
    [ -d "/proc/$pid" ] || continue

    # Skip if no comm file
    [ -f "/proc/$pid/comm" ] || continue

    # Get process info
    uid=$(awk '/^Uid:/ {print $2}' /proc/$pid 2>/dev/null)
    comm=$(cat /proc/$pid/comm 2>/dev/null)
    etimes=$(awk '/^start_time/ {print $2}' /proc/$pid/stat 2>/dev/null)

    # Skip system/root
    if [ "$uid" -eq 0 ]; then
      continue
    fi

    # Skip whitelisted processes
    if is_whitelisted "$comm"; then
      continue
    fi

    # Skip Android core services by name
    case "$comm" in
      system_server|zygote|surfaceflinger|audioserver|mediaserver|netd|vold|servicemanager|healthd)
        continue
        ;;
    esac

    # Determine idle time
    # (We rely on etimes; if missing, skip)
    if [ -z "$etimes" ]; then
      continue
    fi

    # If idle threshold is met, freeze
    if [ "$etimes" -gt "$IDLE_THRESHOLD" ]; then
      if [ "$DRY_RUN" -eq 1 ]; then
        echo "[Freezer] Would freeze $comm ($pid)" >> "$LOG_FILE"
      else
        kill -STOP "$pid" 2>/dev/null || true
        echo "[Freezer] Frozen $comm ($pid)" >> "$LOG_FILE"
      fi
    fi
  done

  sleep 15
done
