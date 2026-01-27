MODULE_NAME := S-OS_v0.2_Test
OUT := out/$(MODULE_NAME)

SCRIPTS := \
	memory_monitor.sh \
	reaper.sh \
	freezer.sh \
	hal.sh \
	dashboard_cli.sh \
	zram_init.sh

all: clean build zip

build:
	@echo "🌿 Building SustainableOS Magisk module..."

	# Directory structure
	mkdir -p $(OUT)/system/bin/s_os
	mkdir -p $(OUT)/common
	mkdir -p $(OUT)/META-INF/com/google/android

	# Copy engine scripts
	for f in $(SCRIPTS); do \
		cp ../modules/sustainability/$$f $(OUT)/system/bin/s_os/; \
	done

	# -------------------------
	# module.prop (generated)
	# -------------------------
	printf "%s\n" \
	"id=sustainable_os" \
	"name=SustainableOS Engine v0.2" \
	"version=v0.2-alpha" \
	"versionCode=2" \
	"author=Builder" \
	"description=Low-RAM optimization engine for MT6762 devices." \
	> $(OUT)/module.prop

	# -------------------------
	# service.sh (generated)
	# -------------------------
	printf "%s\n" \
	"#!/system/bin/sh" \
	"until [ \"\$$\(getprop sys.boot_completed\)\" -eq 1 ]; do sleep 2; done" \
	"/system/bin/s_os/zram_init.sh &" \
	"/system/bin/s_os/memory_monitor.sh &" \
	"/system/bin/s_os/freezer.sh &" \
	"echo \"[S-OS] Engine started\" > /data/local/tmp/s_os_logs/boot.log" \
	> $(OUT)/service.sh
	chmod 0755 $(OUT)/service.sh

	# -------------------------
	# post-fs-data.sh (generated)
	# -------------------------
	printf "%s\n" \
	"#!/system/bin/sh" \
	"magiskpolicy --live \"type sos_engine\"" \
	"magiskpolicy --live \"type sos_engine_exec\"" \
	"magiskpolicy --live \"typeattribute sos_engine domain\"" \
	"magiskpolicy --live \"allow sos_engine self process fork\"" \
	"magiskpolicy --live \"allow sos_engine proc_meminfo file read\"" \
	"magiskpolicy --live \"allow sos_engine sysfs_devices_system_cpu file { read write }\"" \
	"chcon u:object_r:sos_engine_exec:s0 /system/bin/s_os/*.sh" \
	> $(OUT)/common/post-fs-data.sh
	chmod 0755 $(OUT)/common/post-fs-data.sh

zip:
	cd $(OUT) && zip -qr ../$(MODULE_NAME).zip .

clean:
	rm -rf out
