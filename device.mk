#
# SPDX-FileCopyrightText: The LineageOS Project
# SPDX-License-Identifier: Apache-2.0
#

DEVICE_PATH := device/apple/snowcastle

# Defaults
SNOWCASTLE_PARTITION_SCHEME ?= normal
SNOWCASTLE_USE_GENERIC_INIT ?= false
$(warning Using $(SNOWCASTLE_PARTITION_SCHEME) partition scheme)

ifeq ($(SNOWCASTLE_PARTITION_SCHEME),apfs)
SNOWCASTLE_USE_GENERIC_INIT := true
endif

# Inherit from mainline/common
TARGET_ENABLE_FBKEYBOARD := true
TARGET_GRAPHICS_ALLOCATOR_HAL := minigbm-upstream
TARGET_GRAPHICS_COMPOSER_HAL := drmfb-composer
TARGET_HEALTH_HAL := default-aidl
TARGET_INITIAL_BRINGUP := true
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
    generate_firmware \
    generate_firmware.recovery \
    hKernelFWExtractor \
    hKernelFWExtractor.recovery \
    ipsw \
    ipsw.recovery

# Init
PRODUCT_COPY_FILES += \
    $(DEVICE_PATH)/configs/fstab/fstab.$(SNOWCASTLE_PARTITION_SCHEME):$(TARGET_COPY_OUT_VENDOR)/etc/fstab.$(SNOWCASTLE_PARTITION_SCHEME) \
    $(DEVICE_PATH)/configs/fstab/fstab.zram:$(TARGET_COPY_OUT_VENDOR)/etc/fstab.zram \
    $(DEVICE_PATH)/configs/init/init.snowcastle.rc:$(TARGET_COPY_OUT_VENDOR)/etc/init/hw/init.snowcastle.rc \
    $(DEVICE_PATH)/configs/init/ueventd.snowcastle.rc:$(TARGET_COPY_OUT_RECOVERY)/root/vendor/etc/ueventd.rc \
    $(DEVICE_PATH)/configs/init/ueventd.snowcastle.rc:$(TARGET_COPY_OUT_VENDOR)/etc/ueventd.snowcastle.rc

PRODUCT_PACKAGES += \
    use_memfd.rc

$(call soong_config_set,libinit,vendor_init_lib,//$(DEVICE_PATH):init_snowcastle)
$(call soong_config_set,mainline_common_libinit,set_properties_from,devicetree)

ifeq ($(SNOWCASTLE_PARTITION_SCHEME),apfs)
# Not to override statically set dalvik heap
$(call soong_config_set_bool,mainline_common_libinit,set_dalvik_heap,false)
endif

ifeq ($(SNOWCASTLE_USE_GENERIC_INIT),true)
PRODUCT_COPY_FILES += \
    $(DEVICE_PATH)/configs/scripts/vendor_init_recovery:$(TARGET_COPY_OUT_RECOVERY)/root/system/bin/vendor_init

PRODUCT_PACKAGES += \
    generic_init_first_stage \
    generic_init_second_stage.recovery

PRODUCT_PACKAGES += \
    sh_vendor_bootstrap \
    toybox_vendor_bootstrap \
    vendor_init
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
PRODUCT_COPY_FILES += \
    $(DEVICE_PATH)/configs/modprobe/modules.blocklist:$(TARGET_COPY_OUT_RECOVERY)/root/lib/modules/modules.blocklist
ifeq ($(SNOWCASTLE_PARTITION_SCHEME),normal)
PRODUCT_COPY_FILES += \
    $(DEVICE_PATH)/configs/modprobe/modules.blocklist:$(TARGET_COPY_OUT_VENDOR)/lib/modules/modules.blocklist
else
PRODUCT_COPY_FILES += \
    $(DEVICE_PATH)/configs/modprobe/modules.blocklist:$(TARGET_COPY_OUT_VENDOR_DLKM)/lib/modules/modules.blocklist
endif

PRODUCT_PACKAGES += \
    modules.load.normal \
    modules.load.normal.recovery

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
TARGET_FOLLOWS_LATEST_SHIPPING_API_LEVEL := true

# Soong namespaces
PRODUCT_SOONG_NAMESPACES += \
    $(DEVICE_PATH) \
    device/mainline/generic \
    kernel/mainline/configs

# VINTF
TARGET_FOLLOWS_LATEST_VINTF_TARGET_LEVEL := true
