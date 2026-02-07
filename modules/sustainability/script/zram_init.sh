#!/system/bin/sh
# zRAM Optimizer for 1GB Devices (MT6762)
# v0.2 — SustainableOS

# --- Disable existing swap ---
swapoff /dev/block/zram0 2> /dev/null

# --- Reset zRAM ---
echo 1 > /sys/block/zram0/reset

# --- Use LZ4 compression for speed/efficiency ---
echo lz4 > /sys/block/zram0/comp_algorithm

# --- Set disksize (512MB) ---
echo 536870912 > /sys/block/zram0/disksize

# --- Initialize swap and enable ---
mkswap /dev/block/zram0
swapon /dev/block/zram0 -p 100

# --- VM tuning for low-RAM responsiveness ---
echo 100 > /proc/sys/vm/swappiness
echo 10 > /proc/sys/vm/vfs_cache_pressure

echo "[S-OS] zRAM Optimization Complete: 512MB LZ4 active."
