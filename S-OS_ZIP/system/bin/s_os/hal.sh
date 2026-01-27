#!/system/bin/sh
# hal.sh — SustainableOS v0.2
# Hardware Abstraction Layer (CPU / Backlight)

CPU_DIR="/sys/devices/system/cpu"
BACKLIGHT="/sys/class/leds/lcd-backlight/brightness"
SIM_LOG="/tmp/s_os_logs/hal_sim.log"

# --------------------------------------------------
# Safe hardware write (falls back to simulation log)
# --------------------------------------------------
write_hw() {
    local path="$1"
    local value="$2"

    if [ -w "$path" ]; then
        echo "$value" > "$path"
    else
        echo "[SIM] $path <- $value" >> "$SIM_LOG"
    fi
}

# --------------------------------------------------
# CPU frequency limiting
# --------------------------------------------------
eco_cpu_limit() {
    local LIMIT="${1:-1000000}"

    for cpu in "$CPU_DIR"/cpu[0-9]*; do
        [ -d "$cpu/cpufreq" ] || continue
        write_hw "$cpu/cpufreq/scaling_max_freq" "$LIMIT"
    done
}

# --------------------------------------------------
# Backlight control
# --------------------------------------------------
eco_backlight() {
    write_hw "$BACKLIGHT" "${1:-70}"
}

# --------------------------------------------------
# Eco Mode ON
# --------------------------------------------------
eco_mode_on() {
    eco_cpu_limit 1000000
    eco_backlight 70
}

# --------------------------------------------------
# Eco Mode OFF (restore max freq)
# --------------------------------------------------
eco_mode_off() {
    for cpu in "$CPU_DIR"/cpu[0-9]*; do
        MAX="$cpu/cpufreq/cpuinfo_max_freq"
        [ -f "$MAX" ] || continue
        write_hw "$cpu/cpufreq/scaling_max_freq" "$(cat "$MAX")"
    done
    eco_backlight 180
}

# --------------------------------------------------
# Command dispatcher
# --------------------------------------------------
case "$1" in
    eco_mode_on)
        eco_mode_on
        ;;
    eco_mode_off)
        eco_mode_off
        ;;
    eco_cpu_limit)
        eco_cpu_limit "$2"
        ;;
    eco_backlight)
        eco_backlight "$2"
        ;;
    *)
        echo "Usage: hal.sh {eco_mode_on|eco_mode_off|eco_cpu_limit <hz>|eco_backlight <level>}"
        ;;
esac

