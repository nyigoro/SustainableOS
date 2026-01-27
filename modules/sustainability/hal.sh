#!/bin/bash
# hal.sh - Hardware Abstraction Layer for SustainableOS

set -e

# -----------------------------
# CPU Eco Mode (MT6762 Octa-core)
# -----------------------------
eco_cpu_limit() {
    LIMIT=${1:-1000000}  # Default cap frequency in KHz
    echo "🌱 Applying CPU eco-limit: $LIMIT KHz"
    for i in {0..7}; do
        CPU_PATH="/sys/devices/system/cpu/cpu$i/cpufreq/scaling_max_freq"
        if [ -w "$CPU_PATH" ]; then
            echo "$LIMIT" > "$CPU_PATH"
        fi
    done
}

# -----------------------------
# Backlight Adjustment
# -----------------------------
eco_backlight() {
    BRIGHTNESS=${1:-70}
    LED_PATH="/sys/class/leds/lcd-backlight/brightness"
    if [ -w "$LED_PATH" ]; then
        echo "$BRIGHTNESS" > "$LED_PATH"
        echo "🌱 Backlight set to $BRIGHTNESS"
    fi
}

# -----------------------------
# zRAM Configuration
# -----------------------------
setup_zram() {
    SIZE=${1:-536870912}  # Default 512MB
    ZRAM="/sys/block/zram0/disksize"
    if [ -w "$ZRAM" ]; then
        echo "$SIZE" > "$ZRAM"
        mkswap /dev/block/zram0
        swapon /dev/block/zram0
        echo "🌱 zRAM enabled: $(($SIZE/1024/1024)) MB"
    fi
}

# -----------------------------
# Toggle Eco Mode (CPU + Backlight)
# -----------------------------
eco_mode_on() {
    eco_cpu_limit 1000000
    eco_backlight 70
    echo "🌿 Eco Mode ENABLED"
}

eco_mode_off() {
    for i in {0..7}; do
        CPU_PATH="/sys/devices/system/cpu/cpu$i/cpufreq/scaling_max_freq"
        [ -w "$CPU_PATH" ] && cpufreq=$(cat /sys/devices/system/cpu/cpu$i/cpufreq/cpuinfo_max_freq) && echo "$cpufreq" > "$CPU_PATH"
    done
    eco_backlight 255
    echo "🌿 Eco Mode DISABLED"
}
