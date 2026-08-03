#
# SPDX-FileCopyrightText: The LineageOS Project
# SPDX-License-Identifier: Apache-2.0
#

PRODUCT_MAKEFILES := \
    $(LOCAL_DIR)/lineage_snowcastle.mk \
    $(LOCAL_DIR)/snowcastle_legacy/lineage_snowcastle_legacy.mk

$(foreach build_type, user userdebug eng, \
    $(eval COMMON_LUNCH_CHOICES += lineage_snowcastle-$(build_type)) \
    $(eval COMMON_LUNCH_CHOICES += lineage_snowcastle_legacy-$(build_type)))
