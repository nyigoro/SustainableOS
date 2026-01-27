#!/system/bin/sh
# SustainableOS service.sh - Magisk Boot Trigger

# Wait for boot completion
until [ "$(getprop sys.boot_completed)" -eq 1 ]; do
    sleep 2
done

# Ensure permissions
chmod -R 755 /system/bin/s_os/
chown -R root:system /system/bin/s_os/

# Start the core services
/system/bin/s_os/zram_init.sh &
/system/bin/s_os/memory_monitor.sh &
/system/bin/s_os/freezer.sh &

echo "[S-OS] Engine logic started via Magisk service." > /data/local/tmp/s_os_logs/boot.log
