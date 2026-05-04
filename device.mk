#
# SPDX-FileCopyrightText: The LineageOS Project
# SPDX-License-Identifier: Apache-2.0
#

DEVICE_PATH := device/apple/snowcastle

# Defaults
SNOWCASTLE_PARTITION_SCHEME ?= normal
$(warning Using $(SNOWCASTLE_PARTITION_SCHEME) partition scheme)

# Inherit from mainline/common
TARGET_INITIAL_BRINGUP := true
TARGET_USES_FRAMEBUFFER_DISPLAY := true
include device/mainline/common/optional/options.mk
$(call inherit-product, device/mainline/common/mainline_common.mk)

# Bootanimation
TARGET_SCREEN_WIDTH := 300
TARGET_SCREEN_HEIGHT := 300

# Dalvik heap
$(call inherit-product, frameworks/native/build/phone-xhdpi-2048-dalvik-heap.mk)

# HIDL
PRODUCT_PACKAGES += \
    vndservicemanager

# Init
PRODUCT_COPY_FILES += \
    $(DEVICE_PATH)/configs/fstab/fstab.$(SNOWCASTLE_PARTITION_SCHEME):$(TARGET_COPY_OUT_VENDOR)/etc/fstab.$(SNOWCASTLE_PARTITION_SCHEME) \
    $(DEVICE_PATH)/configs/init/init.snowcastle.rc:$(TARGET_COPY_OUT_VENDOR)/etc/init/hw/init.snowcastle.rc \
    $(DEVICE_PATH)/configs/init/ueventd.snowcastle.rc:$(TARGET_COPY_OUT_VENDOR)/etc/ueventd.snowcastle.rc

PRODUCT_PACKAGES += \
    use_memfd.rc

$(call soong_config_set,libinit,vendor_init_lib,//$(DEVICE_PATH):init_snowcastle)
$(call soong_config_set,mainline_common_libinit,set_properties_from,devicetree)

# Images
PRODUCT_BUILD_BOOT_IMAGE := true
PRODUCT_BUILD_DEBUG_BOOT_IMAGE := true
PRODUCT_BUILD_RAMDISK_IMAGE := true
PRODUCT_BUILD_RECOVERY_IMAGE := true
PRODUCT_USE_DYNAMIC_PARTITION_SIZE := true

# Kernel
PRODUCT_OTA_ENFORCE_VINTF_KERNEL_REQUIREMENTS := false

# Overlays
DEVICE_PACKAGE_OVERLAYS += \
    $(DEVICE_PATH)/overlays/overlay

# Page size
PRODUCT_CHECK_PREBUILT_MAX_PAGE_SIZE := true
PRODUCT_MAX_PAGE_SIZE_SUPPORTED := 16384
PRODUCT_NO_BIONIC_PAGE_SIZE_MACRO := true

# Permissions
PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/handheld_core_hardware.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/handheld_core_hardware.xml

# Ramdisk
PRODUCT_COPY_FILES += \
    $(DEVICE_PATH)/configs/fstab/fstab.$(SNOWCASTLE_PARTITION_SCHEME):$(TARGET_COPY_OUT_RAMDISK)/fstab.$(SNOWCASTLE_PARTITION_SCHEME)

# Recovery
PRODUCT_COPY_FILES += \
    $(DEVICE_PATH)/configs/init/init.recovery.snowcastle.rc:$(TARGET_COPY_OUT_RECOVERY)/root/init.recovery.snowcastle.rc

# Shipping API level
PRODUCT_SHIPPING_API_LEVEL := 33

# Soong namespaces
PRODUCT_SOONG_NAMESPACES += \
    $(DEVICE_PATH) \
    kernel/mainline/configs
