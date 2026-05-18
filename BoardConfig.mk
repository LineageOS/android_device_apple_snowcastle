#
# SPDX-FileCopyrightText: The LineageOS Project
# SPDX-License-Identifier: Apache-2.0
#

USES_DEVICE_APPLE_SNOWCASTLE := true

# Kernel
TARGET_BOOTS_16K := true

# Inherit from mainline/common
include device/mainline/common/BoardConfigMainlineCommon.mk

# A/B
AB_OTA_UPDATER := false

# Architecture
TARGET_ARCH := arm64
TARGET_ARCH_VARIANT := armv8-a
TARGET_CPU_ABI := arm64-v8a
TARGET_CPU_ABI2 :=
TARGET_CPU_VARIANT := generic

# Boot parameters
BOARD_KERNEL_CMDLINE := \
    $(MAINLINE_COMMON_ANDROIDBOOT_PARAMS) \
    $(MAINLINE_COMMON_KERNEL_PARAMS) \
    androidboot.fstab_suffix=$(SNOWCASTLE_PARTITION_SCHEME) \
    androidboot.hardware=snowcastle \
    androidboot.serialno=snowcastle \
    androidboot.verifiedbootstate=orange \
    console=tty0

ifeq ($(SNOWCASTLE_PARTITION_SCHEME),apfs)
BOARD_KERNEL_CMDLINE += \
    androidboot.init_fatal_pause=true \
    androidboot.mount_firmware=false \
    androidboot.mount_system=imgs \
    androidboot.mount_userdata=tmpfs \
    rdinit=/system/bin/generic_init
endif

# Display
TARGET_SCREEN_DENSITY := 400

# Filesystem
BOARD_EROFS_BLOCKSIZE := 16384
BOARD_F2FS_BLOCKSIZE := 16384
TARGET_USERIMAGES_SPARSE_EXT_DISABLED := true
TARGET_USERIMAGES_USE_F2FS := true
TARGET_USERIMAGES_USE_EXT4 := true

# Kernel
ifneq ($(wildcard device/apple/snowcastle-kernel/Image.gz-dtb),)
$(warning Using prebuilt kernel)
TARGET_PREBUILT_KERNEL := device/apple/snowcastle-kernel/Image.gz-dtb
else
$(warning Using source-built kernel)
BOARD_KERNEL_IMAGE_NAME := Image.gz
TARGET_KERNEL_SOURCE := kernel/apple/HoolockLinux

TARGET_KERNEL_CONFIG_EXT := \
    $(DEVICE_PATH)/configs/kernel/config-postmarketos-apple-4k.aarch64 \
    $(DEVICE_PATH)/configs/kernel/apple.config \
    kernel/mainline/configs/fragments/android-base-pre/common.config \
    kernel/mainline/configs/fragments/android-base-pre/arm64.config \
    kernel/configs/b/android-6.12/android-base.config \
    kernel/mainline/configs/fragments/android-base-conditional/CONFIG_ARM64-y.config \
    kernel/mainline/configs/fragments/common.config \
    kernel/mainline/configs/fragments/y/arm64/pagesize-16k.config \
    kernel/mainline/configs/fragments/y/fbcon.config \
    kernel/mainline/configs/fragments/n/disable-clang-hardening-features.config \
    kernel/mainline/configs/fragments/n/faster-build-time.config
endif

# Kernel modules
BOARD_RECOVERY_RAMDISK_KERNEL_MODULES_LOAD := \
    $(strip $(shell cat $(DEVICE_PATH)/configs/modprobe/modules.load.basic))
BOARD_VENDOR_KERNEL_MODULES_LOAD := \
    $(BOARD_RECOVERY_RAMDISK_KERNEL_MODULES_LOAD)
BOARD_VENDOR_RAMDISK_KERNEL_MODULES_LOAD :=
BOOT_KERNEL_MODULES :=
RECOVERY_KERNEL_MODULES := \
    $(BOARD_RECOVERY_RAMDISK_KERNEL_MODULES_LOAD)
TARGET_AUTO_COLLECT_KERNEL_MODULE_DEPS := true

ifeq ($(shell grep modules_install $(TARGET_KERNEL_SOURCE)-modules/linux-apfs-rw/Makefile),)
    ifeq ($(SNOWCASTLE_PARTITION_SCHEME),apfs)
        $(error Please clone linux-apfs-rw and adapt it to be buildable.)
    endif
else
    BOARD_RECOVERY_RAMDISK_KERNEL_MODULES_LOAD += apfs.ko
    BOARD_VENDOR_RAMDISK_KERNEL_MODULES_LOAD += apfs.ko
    BOOT_KERNEL_MODULES += apfs.ko
    RECOVERY_KERNEL_MODULES += apfs.ko
    TARGET_KERNEL_EXT_MODULE_ROOT := $(TARGET_KERNEL_SOURCE)-modules
    TARGET_KERNEL_EXT_MODULES := linux-apfs-rw
endif

# OTA
ifneq ($(SNOWCASTLE_PARTITION_SCHEME),normal)
TARGET_SKIP_OTA_PACKAGE := true
endif

# Partitions
BOARD_FLASH_BLOCK_SIZE := 4096
BOARD_USES_METADATA_PARTITION := true
TARGET_COPY_OUT_VENDOR := vendor

ifeq ($(SNOWCASTLE_PARTITION_SCHEME),apfs)
BOARD_SYSTEMIMAGE_FILE_SYSTEM_TYPE := erofs
BOARD_VENDORIMAGE_FILE_SYSTEM_TYPE := erofs
else
BOARD_SYSTEMIMAGE_EXTFS_INODE_COUNT := -1
BOARD_SYSTEMIMAGE_FILE_SYSTEM_TYPE := ext4
BOARD_SYSTEMIMAGE_PARTITION_RESERVED_SIZE := 67108864
BOARD_VENDORIMAGE_EXTFS_INODE_COUNT := -1
BOARD_VENDORIMAGE_FILE_SYSTEM_TYPE := ext4
BOARD_VENDORIMAGE_PARTITION_RESERVED_SIZE := 67108864
endif

# Platform
TARGET_BOARD_PLATFORM := snowcastle

# Recovery
TARGET_RECOVERY_DENSITY := xxhdpi
TARGET_RECOVERY_FSTAB := $(DEVICE_PATH)/configs/fstab/fstab.normal

# VINTF
DEVICE_MANIFEST_FILE := \
    $(DEVICE_PATH)/configs/vintf/manifest.xml
