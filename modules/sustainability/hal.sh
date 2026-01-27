#!/bin/bash
# hal.sh - SustainableOS Hardware Abstraction Layer (MT6762 / Oppo A1k)
# Controls CPU, Backlight, zRAM, and Eco Mode

set -e

# --- Hardware Paths ---
CPU_DIR="/sys/devices/system/cpu"
BACKLIGHT="/sys/class/leds/lcd-backlight/brightness"
ZRAM_DISK="/sys/block/zram0/disksize"

# -----------------------------
# Functions
# -----------------------------
eco_cpu_limit() {
    LIMIT=${1:-1000000}  # Default 1GHz cap
    echo "[HAL] Applying CPU eco-limit: $LIMIT KHz"
    for i in {0..7}; do
        CPU_PATH="$CPU_DIR/cpu$i/cpufreq/scaling_max_freq"
        [ -w "$CPU_PATH" ] && echo "$LIMIT" > "$CPU_PATH"
    done
}

eco_backlight() {
    BRIGHTNESS=${1:-70}
    [ -w "$BACKLIGHT" ] && echo "$BRIGHTNESS" > "$BACKLIGHT" && echo "[HAL] Backlight set to $BRIGHTNESS"
}

setup_zram() {
    SIZE=${1:-536870912}  # Default 512MB
    swapoff /dev/zram0 2>/dev/null || true
    echo 1 > /sys/block/zram0/reset
    [ -w "$ZRAM_DISK" ] && echo "$SIZE" > "$ZRAM_DISK"
    mkswap /dev/zram0
    swapon /dev/zram0 -p 100
    echo "[HAL] zRAM enabled: $(($SIZE/1024/1024)) MB"
}

eco_mode_on() {
    echo "[HAL] Enabling Eco Mode"
    eco_cpu_limit 1000000
    eco_backlight 70
}

eco_mode_off() {
    echo "[HAL] Disabling Eco Mode (Performance Mode)"
    for i in {0..7}; do
        CPU_PATH="$CPU_DIR/cpu$i/cpufreq/scaling_max_freq"
        if [ -f "$CPU_PATH" ]; then
            MAX_FREQ=$(cat "$CPU_DIR/cpu$i/cpufreq/cpuinfo_max_freq")
            echo "$MAX_FREQ" > "$CPU_PATH"
        fi
    done
    eco_backlight 180
}

# -----------------------------
# Main HAL CLI
# -----------------------------
case "$1" in
    eco_mode_on)
        eco_mode_on
        ;;
    eco_mode_off)
        eco_mode_off
        ;;
    init_zram)
        setup_zram 536870912
        ;;
    eco_cpu_limit)
        eco_cpu_limit "$2"
        ;;
    eco_backlight)
        eco_backlight "$2"
        ;;
    *)
        echo "Usage: hal.sh {eco_mode_on|eco_mode_off|init_zram|eco_cpu_limit <khz>|eco_backlight <value>}"
        ;;
esac
