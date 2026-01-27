#!/system/bin/sh
# dashboard_cli.sh — SustainableOS v0.2
# CLI Dashboard (adb shell sos_dashboard)

BASE_DIR="/system/bin/s_os"
LOG_FILE="/tmp/s_os_logs/memory.log"
REAP_LOG="/tmp/s_os_logs/reap_count.log"

clear
echo "📡 Waiting for SustainableOS Engine..."

# Wait until monitor is alive
until [ -s "$LOG_FILE" ] && grep -q MEM_AVAILABLE "$LOG_FILE"; do
    sleep 1
done

BAR_WIDTH=30

while true; do
    MEM_TOTAL=$(grep MEM_TOTAL "$LOG_FILE" | awk '{print $2}')
    MEM_AVAILABLE=$(grep MEM_AVAILABLE "$LOG_FILE" | tail -n1 | awk '{print $2}')

    [ -z "$MEM_TOTAL" ] || [ -z "$MEM_AVAILABLE" ] && sleep 1 && continue

    MEM_PERCENT=$(( MEM_AVAILABLE * 100 / MEM_TOTAL ))
    FILLED=$(( MEM_PERCENT * BAR_WIDTH / 100 ))
    EMPTY=$(( BAR_WIDTH - FILLED ))

    if [ "$MEM_PERCENT" -gt 40 ]; then
        COLOR="\033[32m" # green
    else
        COLOR="\033[31m" # red
    fi

    clear
    echo "🌿 SustainableOS v0.2 Dashboard"
    echo "----------------------------------------"
    printf "RAM: %b" "$COLOR"
    printf "%0.s█" $(seq 1 $FILLED)
    printf "%0.s " $(seq 1 $EMPTY)
    printf "\033[0m %d%%\n" "$MEM_PERCENT"
    echo "----------------------------------------"
    echo "❄️ Frozen : $(ps -eo stat | grep -c '^T')"
    echo "⚡ Active : $(ps -eo stat | grep -c '^[RSDZ]')"
    echo "🪓 Reaps  : $(cat "$REAP_LOG" 2>/dev/null || echo 0)"
    echo "----------------------------------------"
    echo "[E] Eco Mode  |  [Q] Quit"

    read -t 1 -n 1 key
    case "$key" in
        e|E)
            "$BASE_DIR/hal.sh" eco_mode_on
            ;;
        q|Q)
            clear
            exit 0
            ;;
    esac
done

