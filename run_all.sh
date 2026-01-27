#!/bin/bash
# run_all.sh - Launch the full SustainableOS v0.1 engine
set -e

# -----------------------------
# CONFIG
# -----------------------------
MEMORY_THRESHOLD_PERCENT=${MEMORY_THRESHOLD_PERCENT:-15}
MONITOR_INTERVAL=${MONITOR_INTERVAL:-2}
IDLE_THRESHOLD=${IDLE_THRESHOLD:-60}
CHECK_INTERVAL=${CHECK_INTERVAL:-10}
DRY_RUN=${DRY_RUN:-1}

BASE_DIR="$(dirname "$0")/modules/sustainability"
DASH_DIR="$(dirname "$0")/modules/eco_dashboard"
LOG_DIR="/tmp/s_os_logs"
mkdir -p "$LOG_DIR"

# -----------------------------
# Cleanup previous logs / processes
# -----------------------------
echo "🌱 Cleaning old logs and background processes..."
pkill -f memory_monitor.sh || true
pkill -f reaper.sh || true
pkill -f freezer.sh || true
pkill -f dashboard_cli.sh || true

rm -f "$LOG_DIR"/*.log

# -----------------------------
# Launch Memory Monitor
# -----------------------------
echo "🌿 Starting Memory Monitor..."
"$BASE_DIR/memory_monitor.sh" &
MONITOR_PID=$!
echo "Monitor PID: $MONITOR_PID"

# -----------------------------
# Launch Freezer
# -----------------------------
echo "🌿 Starting Freezer..."
"$BASE_DIR/freezer.sh" &
FREEZER_PID=$!
echo "Freezer PID: $FREEZER_PID"

# -----------------------------
# Launch Dashboard CLI
# -----------------------------
echo "🌿 Starting Dashboard CLI..."
"$DASH_DIR/dashboard_cli.sh" &
DASH_PID=$!
echo "Dashboard PID: $DASH_PID"

# -----------------------------
# Wait for all background processes
# -----------------------------
echo "🌱 Sustainability Engine v0.1 running..."
echo "Press Ctrl+C to stop all services."

trap "echo '🌱 Stopping all services...'; kill $MONITOR_PID $FREEZER_PID $DASH_PID; exit" SIGINT SIGTERM

wait
