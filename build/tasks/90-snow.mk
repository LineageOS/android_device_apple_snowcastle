#
# SPDX-FileCopyrightText: The LineageOS Project
# SPDX-License-Identifier: Apache-2.0
#

ifeq ($(USES_DEVICE_APPLE_SNOWCASTLE),true)

MAKE_M1N1_BLOBS_SH_PATH := $(DEVICE_PATH)/configs/scripts/make-m1n1-blobs.sh
INSTALLED_MAKE_M1N1_BLOBS_SH_TARGET := $(PRODUCT_OUT)/make-m1n1-blobs.sh
$(INSTALLED_MAKE_M1N1_BLOBS_SH_TARGET): $(MAKE_M1N1_BLOBS_SH_PATH)
	$(transform-prebuilt-to-target)

MAKE_M1N1_BLOBS_BAT_PATH := $(DEVICE_PATH)/configs/scripts/make-m1n1-blobs.bat
INSTALLED_MAKE_M1N1_BLOBS_BAT_TARGET := $(PRODUCT_OUT)/make-m1n1-blobs.bat
$(INSTALLED_MAKE_M1N1_BLOBS_BAT_TARGET): $(MAKE_M1N1_BLOBS_BAT_PATH)
	$(transform-prebuilt-to-target)

LOCAL_INCLUDE_IN_PRODUCT_OUT += \
    dtb.img \
    kernel \
    m1n1-vars-boot.txt \
    m1n1-vars-recovery.txt \
    make-m1n1-blobs.bat \
    make-m1n1-blobs.sh \
    ramdisk.img \
    ramdisk-recovery.img \
    system.img \
    vendor.img

ifeq ($(BOARD_USES_VENDOR_DLKMIMAGE),true)
LOCAL_INCLUDE_IN_PRODUCT_OUT += \
    vendor_dlkm.img
endif

ifneq ($(INSTALLED_M1N1_TARGET),)
LOCAL_INCLUDE_IN_PRODUCT_OUT += \
    m1n1.bin
ifeq ($(M1N1_SYSCFG_PAYLOAD_PATH),)
LOCAL_INCLUDE_IN_PRODUCT_OUT += \
    m1n1-boot.bin \
    m1n1-recovery.bin
endif # !M1N1_SYSCFG_PAYLOAD_PATH
endif # INSTALLED_M1N1_TARGET

ifneq ($(LINEAGE_BUILD),)
INSTALLED_SNOW_TARGET := $(PRODUCT_OUT)/snowcastle-$(SNOWCASTLE_PARTITION_SCHEME)-LineageOS-$(LINEAGE_VERSION).zip
else
INSTALLED_SNOW_TARGET ?= $(PRODUCT_OUT)/snowcastle-$(SNOWCASTLE_PARTITION_SCHEME)-Android-$(PLATFORM_VERSION_LAST_STABLE)-$(BUILD_ID)-$(LOCAL_BUILD_DATE).zip
endif
INSTALLED_SNOW_TARGET_DEPS_PRODUCT_OUT := $(addprefix $(PRODUCT_OUT)/,$(LOCAL_INCLUDE_IN_PRODUCT_OUT))
LOCAL_SOONG_ZIP_EXEC := $(HOST_OUT_EXECUTABLES)/soong_zip

$(INSTALLED_SNOW_TARGET): $(INSTALLED_SNOW_TARGET_DEPS_PRODUCT_OUT) $(LOCAL_SOONG_ZIP_EXEC)
	$(call pretty,"Project Snowcastle output package: $@")
	$(LOCAL_SOONG_ZIP_EXEC) -o $@ -C $(PRODUCT_OUT) $(foreach f,$(INSTALLED_SNOW_TARGET_DEPS_PRODUCT_OUT), -f $(f))

.PHONY: snow snow-deps
snow: $(INSTALLED_SNOW_TARGET)
snow-deps: $(INSTALLED_SNOW_TARGET_DEPS_PRODUCT_OUT)

endif # USES_DEVICE_APPLE_SNOWCASTLE
