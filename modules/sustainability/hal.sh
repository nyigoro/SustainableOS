#!/bin/bash
# hal.sh — SustainableOS v0.2

CPU_DIR="/sys/devices/system/cpu"
BACKLIGHT="/sys/class/leds/lcd-backlight/brightness"
SIM_LOG="/tmp/s_os_logs/hal_sim.log"

write_hw() {
    local path=$1
    local value=$2
    if [ -w "$path" ]; then
        echo "$value" > "$path"
    else
        echo "[SIM] $path ← $value" >> "$SIM_LOG"
    fi
}

eco_cpu_limit() {
    LIMIT=${1:-1000000}
    for i in {0..7}; do
        write_hw "$CPU_DIR/cpu$i/cpufreq/scaling_max_freq" "$LIMIT"
    done
}

eco_backlight() {
    write_hw "$BACKLIGHT" "${1:-70}"
}

eco_mode_on() {
    eco_cpu_limit 1000000
    eco_backlight 70
}

eco_mode_off() {
    for i in {0..7}; do
        MAX="$CPU_DIR/cpu$i/cpufreq/cpuinfo_max_freq"
        [ -f "$MAX" ] && write_hw "$CPU_DIR/cpu$i/cpufreq/scaling_max_freq" "$(cat "$MAX")"
    done
    eco_backlight 180
}

case "$1" in
    eco_mode_on) eco_mode_on ;;
    eco_mode_off) eco_mode_off ;;
    eco_cpu_limit) eco_cpu_limit "$2" ;;
    eco_backlight) eco_backlight "$2" ;;
    *) echo "hal.sh {eco_mode_on|eco_mode_off|eco_cpu_limit|eco_backlight}" ;;
<<<<<<< HEAD
esac

=======
>>>>>>> 1316ce836c9519eb6063163f43f0c37407ce7746
=======
esac
>>>>>>> 0de3f92d58c4c7e752fc2dff351b5e854d2665dc

