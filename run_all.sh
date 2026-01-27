#!/bin/bash
# run_all.sh — SustainableOS v0.2
set -e

BASE_DIR="$(dirname "$0")/modules/sustainability"
DASH_DIR="$(dirname "$0")/modules/eco_dashboard"
LOG_DIR="/tmp/s_os_logs"

mkdir -p "$LOG_DIR"
pkill -f memory_monitor.sh || true
pkill -f freezer.sh || true
pkill -f dashboard_cli.sh || true

bash "$BASE_DIR/memory_monitor.sh" &
MON_PID=$!

bash "$BASE_DIR/freezer.sh" &
FREEZE_PID=$!

bash "$DASH_DIR/dashboard_cli.sh" &
DASH_PID=$!

trap "kill $MON_PID $FREEZE_PID $DASH_PID 2>/dev/null" SIGINT SIGTERM
wait




