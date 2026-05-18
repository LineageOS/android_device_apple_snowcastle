#
# SPDX-FileCopyrightText: The LineageOS Project
# SPDX-License-Identifier: Apache-2.0
#

ifeq ($(USES_DEVICE_APPLE_SNOWCASTLE),true)

M1N1_BIN_PATH := $(DEVICE_PATH)/prebuilts/m1n1.bin

INSTALLED_M1N1_BOOT_TARGET := $(PRODUCT_OUT)/m1n1-boot.bin
INSTALLED_M1N1_BOOT_TARGET_DEPS := \
	$(PRODUCT_OUT)/kernel \
	$(PRODUCT_OUT)/ramdisk.img

$(INSTALLED_M1N1_BOOT_TARGET): $(INSTALLED_M1N1_BOOT_TARGET_DEPS)
	cat $(M1N1_BIN_PATH) <(echo "chosen.bootargs=$(strip $(BOARD_KERNEL_CMDLINE) $(BOARD_KERNEL_CMDLINE_BOOT))") \
		`find $(PRODUCT_OUT)/obj/KERNEL_OBJ/arch/arm64/boot/dts/apple/ -type f -name '*.dtb'` \
		$(INSTALLED_M1N1_BOOT_TARGET_DEPS) > $@

.PHONY: m1n1-boot
m1n1-boot: $(INSTALLED_M1N1_BOOT_TARGET)

INSTALLED_M1N1_BOOT_DEBUG_TARGET := $(PRODUCT_OUT)/m1n1-boot_debug.bin
INSTALLED_M1N1_BOOT_DEBUG_TARGET_DEPS := \
	$(PRODUCT_OUT)/kernel \
	$(PRODUCT_OUT)/ramdisk-debug.img

$(INSTALLED_M1N1_BOOT_DEBUG_TARGET): $(INSTALLED_M1N1_BOOT_DEBUG_TARGET_DEPS)
	cat $(M1N1_BIN_PATH) <(echo "chosen.bootargs=$(strip $(BOARD_KERNEL_CMDLINE) $(BOARD_KERNEL_CMDLINE_BOOT))") \
		`find $(PRODUCT_OUT)/obj/KERNEL_OBJ/arch/arm64/boot/dts/apple/ -type f -name '*.dtb'` \
		$(INSTALLED_M1N1_BOOT_DEBUG_TARGET_DEPS) > $@

.PHONY: m1n1-boot_debug
m1n1-boot_debug: $(INSTALLED_M1N1_BOOT_DEBUG_TARGET)

INSTALLED_M1N1_RECOVERY_TARGET := $(PRODUCT_OUT)/m1n1-recovery.bin
INSTALLED_M1N1_RECOVERY_TARGET_DEPS := \
	$(PRODUCT_OUT)/kernel \
	$(PRODUCT_OUT)/ramdisk-recovery.img

$(INSTALLED_M1N1_RECOVERY_TARGET): $(INSTALLED_M1N1_RECOVERY_TARGET_DEPS)
	cat $(M1N1_BIN_PATH) <(echo "chosen.bootargs=$(strip $(BOARD_KERNEL_CMDLINE) $(BOARD_KERNEL_CMDLINE_RECOVERY))") \
		`find $(PRODUCT_OUT)/obj/KERNEL_OBJ/arch/arm64/boot/dts/apple/ -type f -name '*.dtb'` \
		$(INSTALLED_M1N1_RECOVERY_TARGET_DEPS) > $@

.PHONY: m1n1-recovery
m1n1-recovery: $(INSTALLED_M1N1_RECOVERY_TARGET)

endif # USES_DEVICE_APPLE_SNOWCASTLE
