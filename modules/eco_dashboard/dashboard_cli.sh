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

<<<<<<< HEAD
    BAR_WIDTH=30
=======
    # Color-coded bar
    BAR_WIDTH=30
>>>>>>> 1316ce836c9519eb6063163f43f0c37407ce7746
    FILLED=$(( MEM_PERCENT * BAR_WIDTH / 100 ))
    EMPTY=$(( BAR_WIDTH - FILLED ))
<<<<<<< HEAD

    [ "$MEM_PERCENT" -gt 40 ] && COLOR="\e[32m" || COLOR="\e[31m"

=======
    [ "$MEM_PERCENT" -gt 40 ] && COLOR="\e[32m" || COLOR="\e[31m"
    
    # Display
>>>>>>> 1316ce836c9519eb6063163f43f0c37407ce7746
    clear
<<<<<<< HEAD
    echo -e "🌿 SustainableOS v0.2 Dashboard"
    echo -e "RAM: ${COLOR}$(printf '%0.s█' $(seq 1 $FILLED))$(printf '%0.s ' $(seq 1 $EMPTY))\e[0m $MEM_PERCENT%"
    echo "--------------------------------"
    echo "❄️ Frozen: $(ps -eo stat | grep -c '^T')"
    echo "⚡ Active: $(ps -eo stat | grep -c '^[RSDZ]')"
    echo "🪓 Reaps: $(cat "$REAP_LOG" 2>/dev/null || echo 0)"
    echo "--------------------------------"
    echo "[E] Eco Mode  |  [Q] Quit"
=======
    echo -e "🌿 SustainableOS v0.2 Dashboard"
    echo -e "RAM Usage: [$(printf '%0.s#' $(seq 1 $FILLED))$(printf '%0.s ' $(seq 1 $EMPTY))] $MEM_PERCENT%"
    echo "----------------------------------------"
    echo "❄️ Frozen: $(ps -eo stat | grep -c "^T") | ⚡ Active: $(ps -eo stat | grep -c "^[RSDZ]")"
    echo "🪓 Total Reaps: $(cat $REAP_LOG 2>/dev/null || echo 0)"
    echo "----------------------------------------"
    echo "[E] Toggle Eco Mode | [Q] Quit"
>>>>>>> 1316ce836c9519eb6063163f43f0c37407ce7746

<<<<<<< HEAD
    read -t 1 -n 1 key
    [[ $key == "e" ]] && "$BASE_DIR/hal.sh" eco_mode_on
    [[ $key == "q" ]] && exit 0
=======
    read -t 1 -n 1 key
    [[ $key == "e" ]] && bash "$BASE_DIR/hal.sh" eco_mode_on
    [[ $key == "q" ]] && exit 0
>>>>>>> 1316ce836c9519eb6063163f43f0c37407ce7746
done
