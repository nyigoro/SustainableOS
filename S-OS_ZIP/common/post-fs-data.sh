#!/system/bin/sh
# Live SELinux Policy Injection for SustainableOS

# Define domain types
magiskpolicy --live "type sos_engine"
magiskpolicy --live "type sos_engine_exec"
magiskpolicy --live "typeattribute sos_engine domain"

# Inject rules
magiskpolicy --live "allow sos_engine self process fork"
magiskpolicy --live "allow sos_engine proc_meminfo file read"
magiskpolicy --live "allow sos_engine sysfs_devices_system_cpu file { read write }"
magiskpolicy --live "allow sos_engine sysfs_leds file { read write }"
magiskpolicy --live "allow sos_engine sysfs_zram file { read write }"
magiskpolicy --live "allow sos_engine untrusted_app process { signal sigkill }"

# Label scripts
chcon u:object_r:sos_engine_exec:s0 /system/bin/s_os/*.sh
