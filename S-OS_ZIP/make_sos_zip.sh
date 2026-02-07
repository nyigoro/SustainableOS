#!/bin/bash
# =====================================================
# make_sos_zip.sh — SustainableOS v0.3.1 ZIP Packager
# =====================================================

OUT="S-OS_v0.3.1_Module"
ZIP_NAME="SustainableOS_v0.3.1.zip"

# Create directories
mkdir -p $OUT/system/bin/s_os
mkdir -p $OUT/system/etc/sustainableos
mkdir -p $OUT/META-INF/com/google/android
mkdir -p $OUT/common

echo "[*] Copying SustainableOS scripts..."
cp modules/sustainability/*.sh $OUT/system/bin/s_os/
cp modules/eco_dashboard/dashboard_cli.sh $OUT/system/bin/s_os/
cp modules/sustainability/whitelist*.txt $OUT/system/etc/sustainableos/

echo "[*] Generating module metadata..."
cat <<EOF > $OUT/module.prop
id=sustainable_os
name=SustainableOS Engine
version=v0.3.1
versionCode=301
author=SustainableOS Team
description=Real-time memory & power optimization with OEM-aware Reaper v0.3.1
EOF

echo "[*] Creating SELinux Live Injector (post-fs-data)..."
cat <<'EOF' > $OUT/common/post-fs-data.sh
#!/system/bin/sh
# Injecting sos_engine domain live into kernel
magiskpolicy --live "type sos_engine" "typeattribute sos_engine domain" \
  "allow sos_engine self process fork" \
  "allow sos_engine proc_meminfo file read" \
  "allow sos_engine sysfs_devices_system_cpu file { read write }" \
  "allow sos_engine sysfs_leds file { read write }" \
  "allow sos_engine untrusted_app process { signal sigkill }"
# Label binaries
chcon u:object_r:sos_engine_exec:s0 /system/bin/s_os/*.sh
EOF

echo "[*] Setting up Magisk Boot Trigger (service.sh)..."
cat <<'EOF' > $OUT/service.sh
#!/system/bin/sh
# Wait for boot completion
until [ "$(getprop sys.boot_completed)" -eq 1 ]; do
    sleep 2
done

# Ensure permissions
chmod -R 755 /system/bin/s_os/
chown -R root:system /system/bin/s_os/

# Start core services
/system/bin/s_os/zram_init.sh &
/system/bin/s_os/memory_monitor.sh &
/system/bin/s_os/freezer.sh &

echo "[S-OS] Engine logic started via Magisk service." > /data/local/tmp/s_os_logs/boot.log
EOF

echo "[*] Finalizing ZIP..."
cd $OUT && zip -r ../$ZIP_NAME .
echo "✅ $ZIP_NAME is ready for flashing!"
