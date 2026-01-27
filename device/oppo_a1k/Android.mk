LOCAL_PATH := $(call my-dir)

# =====================================================
# SustainableOS v0.2 — Legacy Make Integration
# =====================================================

# -----------------------------------------------------
# 1. Install Shell Scripts into /system/bin/s_os
# -----------------------------------------------------

define define-sos-script
include $(CLEAR_VARS)
LOCAL_MODULE := $(1)
LOCAL_SRC_FILES := $(1)
LOCAL_MODULE_CLASS := EXECUTABLES
LOCAL_MODULE_PATH := $(TARGET_OUT)/bin/s_os
LOCAL_MODULE_TAGS := optional
LOCAL_MODULE_SUFFIX :=
include $(BUILD_PREBUILT)
endef

SOS_SCRIPTS := \
    run_all.sh \
    memory_monitor.sh \
    reaper.sh \
    freezer.sh \
    hal.sh \
    zram_init.sh \
    dashboard_cli.sh

$(foreach script,$(SOS_SCRIPTS),$(eval $(call define-sos-script,$(script))))

# -----------------------------------------------------
# 2. Init Script (goes to /system/etc/init)
# -----------------------------------------------------

include $(CLEAR_VARS)
LOCAL_MODULE := init.sustainableos.rc
LOCAL_SRC_FILES := init.sustainableos.rc
LOCAL_MODULE_CLASS := ETC
LOCAL_MODULE_PATH := $(TARGET_OUT_ETC)/init
LOCAL_MODULE_TAGS := optional
include $(BUILD_PREBUILT)

# -----------------------------------------------------
# 3. Whitelist Configuration
# -----------------------------------------------------

include $(CLEAR_VARS)
LOCAL_MODULE := sos_whitelist
LOCAL_SRC_FILES := whitelist.txt
LOCAL_MODULE_CLASS := ETC
LOCAL_MODULE_PATH := $(TARGET_OUT_ETC)/sustainableos
LOCAL_MODULE_TAGS := optional
LOCAL_MODULE_FILENAME := whitelist.txt
include $(BUILD_PREBUILT)

# -----------------------------------------------------
# 4. SELinux Policy Registration
# -----------------------------------------------------
# This tells the build system to compile your policy
# into the system sepolicy binary.

BOARD_SEPOLICY_DIRS += \
    $(LOCAL_PATH)/sepolicy
