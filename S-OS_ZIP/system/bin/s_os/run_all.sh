#!/system/bin/sh
# run_all.sh — SustainableOS v0.2
set -e

BASE_DIR="$(dirname "$0")/modules/sustainability"
DASH_DIR="$(dirname "$0")/modules/eco_dashboard"
LOG_DIR="/tmp/s_os_logs"

mkdir -p "$LOG_DIR"

# Kill any old instances
pkill -f memory_monitor.sh || true
pkill -f freezer.sh || true
pkill -f reaper.sh || true
pkill -f dashboard_cli.sh || true

# Start services
bash "$BASE_DIR/memory_monitor.sh" &
MON_PID=$!

bash "$BASE_DIR/freezer.sh" &
FREEZE_PID=$!

bash "$BASE_DIR/reaper.sh" &
REAPER_PID=$!

bash "$DASH_DIR/dashboard_cli.sh" &
DASH_PID=$!

# Graceful shutdown
trap "kill $MON_PID $FREEZE_PID $REAPER_PID $DASH_PID 2>/dev/null" SIGINT SIGTERM
wait
