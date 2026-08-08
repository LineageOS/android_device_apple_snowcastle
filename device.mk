#
# SPDX-FileCopyrightText: The LineageOS Project
# SPDX-License-Identifier: Apache-2.0
#

DEVICE_PATH := device/apple/snowcastle

# Defaults
SNOWCASTLE_PARTITION_SCHEME ?= normal
SNOWCASTLE_USE_GENERIC_INIT ?= false
$(warning Using $(SNOWCASTLE_PARTITION_SCHEME) partition scheme)

ifeq ($(SNOWCASTLE_PARTITION_SCHEME),normal)
SNOWCASTLE_USE_GENERIC_INIT := true
endif

# Inherit from mainline/common
TARGET_HEALTH_HAL := default-aidl
TARGET_INITIAL_BRINGUP := true
TARGET_USES_FRAMEBUFFER_DISPLAY := true
include device/mainline/common/optional/options.mk
$(call inherit-product, device/mainline/common/mainline_common.mk)

# APEX
OVERRIDE_PRODUCT_COMPRESSED_APEX := false

# Bluetooth
PRODUCT_PACKAGES += \
    hcdpack \
    hcdpack.recovery

# Bootanimation
ifeq ($(PRODUCT_IS_GO),true)
TARGET_SCREEN_WIDTH := 100
TARGET_SCREEN_HEIGHT := 100
else
TARGET_SCREEN_WIDTH := 300
TARGET_SCREEN_HEIGHT := 300
endif

# Dalvik heap
ifeq ($(PRODUCT_IS_GO),true)
$(call inherit-product, frameworks/native/build/phone-hdpi-512-dalvik-heap.mk)
else ifeq ($(SNOWCASTLE_PARTITION_SCHEME),apfs)
# APFS stores userdata in RAM, so let's save some RAM
$(call inherit-product, frameworks/native/build/phone-xhdpi-1024-dalvik-heap.mk)
else
$(call inherit-product, frameworks/native/build/phone-xhdpi-2048-dalvik-heap.mk)
endif

# Firmware
PRODUCT_COPY_FILES += \
    $(call find-copy-subdir-files,*,$(DEVICE_PATH)/prebuilts/firmware/,$(TARGET_COPY_OUT_VENDOR)/firmware/)

PRODUCT_PACKAGES += \
    hKernelFWExtractor \
    hKernelFWExtractor.recovery \
    ipsw \
    ipsw.recovery

# HIDL
PRODUCT_PACKAGES += \
    vndservicemanager

# Init
PRODUCT_COPY_FILES += \
    $(DEVICE_PATH)/configs/fstab/fstab.$(SNOWCASTLE_PARTITION_SCHEME):$(TARGET_COPY_OUT_VENDOR)/etc/fstab.$(SNOWCASTLE_PARTITION_SCHEME) \
    $(DEVICE_PATH)/configs/fstab/fstab.zram:$(TARGET_COPY_OUT_VENDOR)/etc/fstab.zram \
    $(DEVICE_PATH)/configs/init/init.snowcastle.rc:$(TARGET_COPY_OUT_VENDOR)/etc/init/hw/init.snowcastle.rc \
    $(DEVICE_PATH)/configs/init/ueventd.snowcastle.rc:$(TARGET_COPY_OUT_VENDOR)/etc/ueventd.snowcastle.rc

PRODUCT_PACKAGES += \
    use_memfd.rc

$(call soong_config_set,libinit,vendor_init_lib,//$(DEVICE_PATH):init_snowcastle)
$(call soong_config_set,mainline_common_libinit,set_properties_from,devicetree)

ifneq ($(SNOWCASTLE_PARTITION_SCHEME),normal)
PRODUCT_PACKAGES += \
    generic_init_first_stage
$(call soong_config_set_bool,mainline_common_libinit,set_dalvik_heap,false)
endif

# Input
PRODUCT_PACKAGES += \
    makez2fw \
    makez2fw.recovery

# Images
PRODUCT_BUILD_BOOT_IMAGE := true
PRODUCT_BUILD_DEBUG_BOOT_IMAGE := true
PRODUCT_BUILD_RAMDISK_IMAGE := true
PRODUCT_BUILD_RECOVERY_IMAGE := true
PRODUCT_USE_DYNAMIC_PARTITION_SIZE := true

# Kernel
PRODUCT_OTA_ENFORCE_VINTF_KERNEL_REQUIREMENTS := false

# Kernel modules
PRODUCT_PACKAGES += \
    modprobe_kernel

# Overlays
DEVICE_PACKAGE_OVERLAYS += \
    $(DEVICE_PATH)/overlays/overlay

PRODUCT_PACKAGES += \
    MainlineGenericWifiOverlay

ifneq ($(LINEAGE_BUILD),)
DEVICE_PACKAGE_OVERLAYS += \
    $(DEVICE_PATH)/overlays/overlay-lineage
endif

# Page size
PRODUCT_CHECK_PREBUILT_MAX_PAGE_SIZE := true

# Permissions
PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.hardware.touchscreen.multitouch.jazzhand.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.touchscreen.multitouch.jazzhand.xml \
    frameworks/native/data/etc/handheld_core_hardware.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/handheld_core_hardware.xml

# Ramdisk
PRODUCT_COPY_FILES += \
    $(call find-copy-subdir-files,*,$(DEVICE_PATH)/prebuilts/firmware/,$(TARGET_COPY_OUT_RAMDISK)/vendor/firmware/) \
    $(DEVICE_PATH)/configs/fstab/fstab.$(SNOWCASTLE_PARTITION_SCHEME):$(TARGET_COPY_OUT_RAMDISK)/fstab.$(SNOWCASTLE_PARTITION_SCHEME)

# Recovery
PRODUCT_COPY_FILES += \
    $(call find-copy-subdir-files,*,$(DEVICE_PATH)/prebuilts/firmware/,$(TARGET_COPY_OUT_RECOVERY)/root/vendor/firmware/) \
    $(DEVICE_PATH)/configs/init/init.recovery.snowcastle.rc:$(TARGET_COPY_OUT_RECOVERY)/root/init.recovery.snowcastle.rc

# Shipping API level
PRODUCT_SHIPPING_API_LEVEL := 33

# Soong namespaces
PRODUCT_SOONG_NAMESPACES += \
    $(DEVICE_PATH) \
    device/mainline/generic \
    kernel/mainline/configs
