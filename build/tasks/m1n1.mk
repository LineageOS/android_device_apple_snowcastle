#
# SPDX-FileCopyrightText: The LineageOS Project
# SPDX-License-Identifier: Apache-2.0
#

ifeq ($(USES_DEVICE_APPLE_SNOWCASTLE),true)

M1N1_BIN_PATH := $(DEVICE_PATH)/prebuilts/m1n1.bin
M1N1_SYSCFG_PAYLOAD_PATH := $(DEVICE_PATH)/prebuilts/m1n1-syscfg.payload

ifeq ($(wildcard $(M1N1_SYSCFG_PAYLOAD_PATH)),)
$(warning $(M1N1_SYSCFG_PAYLOAD_PATH) is missing)
M1N1_SYSCFG_PAYLOAD_PATH :=
endif

# $(1): output file
# $(2): additional cmdline
# $(3): ramdisk image filename
define make-m1n1-blob-target
	cat $(M1N1_BIN_PATH) <(echo "chosen.bootargs=$(strip $(BOARD_KERNEL_CMDLINE) $(2))") \
		$(INSTALLED_DTBIMAGE_TARGET) \
		$(M1N1_SYSCFG_PAYLOAD_PATH) \
		$(PRODUCT_OUT)/kernel \
		$(PRODUCT_OUT)/$(3) > $@
endef

# $(1): variant name
# $(2): ramdisk image filename
define define-m1n1-blob
INSTALLED_M1N1_$(call to-upper,$(1))_TARGET := $(PRODUCT_OUT)/m1n1-$(1).bin
INSTALLED_M1N1_$(call to-upper,$(1))_TARGET_DEPS := \
	$$(INSTALLED_DTBIMAGE_TARGET) \
	$$(M1N1_BIN_PATH) \
	$$(M1N1_SYSCFG_PAYLOAD_PATH) \
	$$(PRODUCT_OUT)/kernel \
	$$(PRODUCT_OUT)/$(2)

$$(INSTALLED_M1N1_$(call to-upper,$(1))_TARGET): $$(INSTALLED_M1N1_$(call to-upper,$(1))_TARGET_DEPS)
	$$(call make-m1n1-blob-target,$$@,$$(BOARD_KERNEL_CMDLINE_$(call to-upper,$(1))),$(2))

.PHONY: m1n1-$(1)
m1n1-$(1): $$(INSTALLED_M1N1_$(call to-upper,$(1))_TARGET)
endef

$(eval $(call define-m1n1-blob,boot,ramdisk.img))
$(eval $(call define-m1n1-blob,boot_debug,ramdisk-debug.img))
$(eval $(call define-m1n1-blob,recovery,ramdisk-recovery.img))

endif # USES_DEVICE_APPLE_SNOWCASTLE
