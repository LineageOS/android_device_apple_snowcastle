#
# SPDX-FileCopyrightText: The LineageOS Project
# SPDX-License-Identifier: Apache-2.0
#

ifeq ($(USES_DEVICE_APPLE_SNOWCASTLE),true)

# $(1): variant name
define define-m1n1-vars-txt
INSTALLED_M1N1_VARS_$(call to-upper,$(1))_TXT_TARGET := $(PRODUCT_OUT)/m1n1-vars-$(1).txt

$$(INSTALLED_M1N1_VARS_$(call to-upper,$(1))_TXT_TARGET):
	echo "chosen.bootargs=$$(strip $$(BOARD_KERNEL_CMDLINE) $$(BOARD_KERNEL_CMDLINE_$(call to-upper,$(1))))" > $$@

.PHONY: m1n1-vars-$(1)
m1n1-vars-$(1): $$(INSTALLED_M1N1_VARS_$(call to-upper,$(1))_TXT_TARGET)
endef

$(eval $(call define-m1n1-vars-txt,boot))
$(eval $(call define-m1n1-vars-txt,boot_debug))
$(eval $(call define-m1n1-vars-txt,recovery))

endif # USES_DEVICE_APPLE_SNOWCASTLE
